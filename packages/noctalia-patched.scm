(define-module (packages noctalia-patched)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (noctalia)
  #:export (noctalia-patched))

;; The noctalia channel's own noctalia-git sources from the channel checkout
;; itself (version "latest"), so its source moves with every `guix pull' and
;; drags a rebuild along with it -- and there are never substitutes for it.
;; Fetch an explicit commit instead so the source is decoupled from the
;; channel.  This is the commit behind the last known-good build, home
;; generation 257 (2026-06-26); it is also what noctalia-mango-tag-names.patch
;; was written against, so pinning keeps the patch applying cleanly.
;;
;; To move the pin: update %noctalia-commit, then
;;   git fetch --depth 1 origin <commit> && git checkout FETCH_HEAD
;;   guix hash -x -S nar -H sha256 -f nix-base32 .
(define %noctalia-commit "74fc383681641691025418b3f9d32bd624dc394e")

(define-public noctalia-patched
  (package
    (inherit noctalia-git)
    (name "noctalia-patched")
    (version (git-version "0" "0" %noctalia-commit))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/noctalia-dev/noctalia")
             (commit %noctalia-commit)))
       (file-name (git-file-name "noctalia" %noctalia-commit))
       (sha256
        (base32 "04rdpcnq0lipmyar5svib7542sxcmd9g2fzyavilh1777amyw55x"))))
    (arguments
     (substitute-keyword-arguments (package-arguments noctalia-git)
       ((#:phases phases)
        #~(modify-phases #$phases
            (add-after 'prepare-for-build 'add-mango-tag-names
              (lambda _
                (invoke "patch" "-p1" "--input"
                        #$(local-file "noctalia-mango-tag-names.patch"))))))))))
