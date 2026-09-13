(define-module (packages pinned)
  #:use-module (guix channels)
  #:use-module (guix inferior)
  #:use-module (srfi srfi-1)
  #:export (ungoogled-chromium-wayland/pinned))

;; Guix revision that ships ungoogled-chromium 147.0.7727.137, whose output is
;; already built in the store.  Later revisions bumped it to 151, which has no
;; aarch64 substitute and takes ~7h to compile here.  Matches channels-lock.scm.
(define %chromium-guix-commit
  "d1e9e23fd441fce828fa74616271b00b90853cee")

(define %chromium-guix-channel
  (channel
   (name 'guix)
   (url "https://git.guix.gnu.org/guix.git")
   (branch "master")
   (commit %chromium-guix-commit)
   (introduction
    (make-channel-introduction
     "9edb3f66fd807b096b48283debdcddccfea34bad"
     (openpgp-fingerprint
      "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA")))))

(define ungoogled-chromium-wayland/pinned
  (first (lookup-inferior-packages
          (inferior-for-channels (list %chromium-guix-channel))
          "ungoogled-chromium-wayland")))
