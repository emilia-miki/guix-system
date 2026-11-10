(define-module (packages pinned)
  #:use-module (guix build-system trivial)
  #:use-module (guix channels)
  #:use-module (guix gexp)
  #:use-module (guix inferior)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages bash)
  #:use-module (srfi srfi-1)
  #:export (ungoogled-chromium-wayland/pinned
            blender-wayland/pinned
            libreoffice-aarch64/pinned))

;; The packages here take hours to compile on this machine and have no aarch64
;; substitutes, so they come from fixed Guix revisions: `guix pull' can move on
;; without rebuilding them.
(define (guix-channel-at commit)
  (channel
   (name 'guix)
   (url "https://git.guix.gnu.org/guix.git")
   (branch "master")
   (commit commit)
   (introduction
    (make-channel-introduction
     "9edb3f66fd807b096b48283debdcddccfea34bad"
     (openpgp-fingerprint
      "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA")))))

;; To move this pin, change the commit.  Blender and LibreOffice then rebuild,
;; and packages/pinned/*.scm must still evaluate against the new revision.
(define %pinned-guix-commit
  "39fa898ce63efad6a320fb1ef2a59f9a6ee258b2")

;; The overrides in packages/pinned/ have to be evaluated by the pinned Guix,
;; because `inherit' needs a real package and an inferior package is not one.
;; So add that directory to the inferior's package path.
(define %pinned-inferior
  (let ((inferior (inferior-for-channels
                   (list (guix-channel-at %pinned-guix-commit))))
        (root (dirname (current-source-directory))))
    (inferior-eval
     `(begin
        (use-modules (gnu packages))
        (set! %load-path (cons ,root %load-path))
        (%package-module-path
         (cons (cons ,root "packages/pinned") (%package-module-path))))
     inferior)
    inferior))

;; Guix revision that ships ungoogled-chromium 147.0.7727.137, whose output is
;; already built in the store.  Later revisions have no aarch64 substitute: 151
;; failed to build here after ~10h on 2026-09-14, and 156 needs about 14h at 8
;; jobs and more at a RAM-safe job count.
(define %chromium-guix-commit
  "d1e9e23fd441fce828fa74616271b00b90853cee")

(define %chromium-inferior
  (inferior-for-channels (list (guix-channel-at %chromium-guix-commit))))

(define (pinned-package inferior name)
  (first (lookup-inferior-packages inferior name)))

;; This revision builds Chromium with rtc_use_pipewire but not rtc_link_pipewire
;; (Guix dropped it for 139 and restored it for 153), so it dlopens
;; libpipewire-0.3.so.0 by bare name and fails to find it, which limits screen
;; sharing to Chromium's own tabs.  Put PipeWire on the library path; it comes
;; from the same revision so its libraries match Chromium's across channel
;; updates.  Drop this wrapper once the pin moves to 153 or later.
(define ungoogled-chromium-wayland/pinned
  (let ((chromium (pinned-package %chromium-inferior
                                  "ungoogled-chromium-wayland"))
        (pipewire (pinned-package %chromium-inferior "pipewire")))
    (package
      (name (inferior-package-name chromium))
      (version (inferior-package-version chromium))
      (source #f)
      (build-system trivial-build-system)
      (arguments
       (list
        #:modules '((guix build union) (guix build utils))
        #:builder
        #~(begin
            (use-modules (guix build union) (guix build utils))
            (let ((wrapper (string-append #$output "/bin/chromium"))
                  (desktop "/share/applications/chromium.desktop"))
              (union-build #$output (list #$chromium)
                           #:create-all-directories? #t)
              (delete-file wrapper)
              (call-with-output-file wrapper
                (lambda (port)
                  (format port "#!~a/bin/bash
export LD_LIBRARY_PATH=\"~a/lib${LD_LIBRARY_PATH:+:}$LD_LIBRARY_PATH\"
exec ~a/bin/chromium \"$@\"\n"
                          #$bash-minimal #$pipewire #$chromium)))
              (chmod wrapper #o555)
              ;; The menu entries hold absolute paths to the inner wrapper.
              (delete-file (string-append #$output desktop))
              (copy-file (string-append #$chromium desktop)
                         (string-append #$output desktop))
              (substitute* (string-append #$output desktop)
                ((#$chromium) #$output))))))
      (native-search-paths (inferior-package-native-search-paths chromium))
      (home-page (inferior-package-home-page chromium))
      (synopsis (inferior-package-synopsis chromium))
      (description (inferior-package-description chromium))
      (license license:bsd-3))))

(define blender-wayland/pinned
  (pinned-package %pinned-inferior "blender-wayland"))

(define libreoffice-aarch64/pinned
  (pinned-package %pinned-inferior "libreoffice-aarch64"))
