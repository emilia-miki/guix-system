(define-module (packages mangowm)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix utils)
  #:use-module (gnu packages wm)
  #:use-module (mangowm)
  #:export (mangowm-git))

;; mango 0.14.4 bumped its meson.build to require wlroots-0.20 and scenefx-0.5,
;; but the mangowm channel's package still lists wlroots-0.19 and guix's stock
;; scenefx (0.4.1, built against wlroots-0.19).  Build scenefx 0.5 against
;; wlroots-0.20 and point mango at both so the channel builds again.
(define scenefx-0.5
  (package
    (inherit scenefx)
    (version "0.5")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/wlrfx/scenefx")
             (commit "0.5")))
       (file-name (git-file-name "scenefx" "0.5"))
       (sha256
        (base32 "0klxy73125lp9jab8qghh4v6di91l3y2rgan4m4lhv5flwdwnj5x"))))
    (inputs
     (modify-inputs (package-inputs scenefx)
       (replace "wlroots" wlroots-0.20)))))

;; The mangowm channel's mangowm-git sources from the channel checkout itself
;; (version "git"), so its source moves with every `guix pull'.  Fetch an
;; explicit commit instead.
;;
;; The commit is constrained from both sides.  Anything before 2026-07-12 still
;; asks meson for wlroots-0.19, which the overrides above cannot satisfy;
;; anything after 2026-07-20 has drifted far enough that mango-tag-names.patch
;; no longer applies (5 of 9 hunks fail on 0.16.1).  3d05901 is mango 0.15.4,
;; the newest commit inside that window: wlroots-0.20 + scenefx-0.5, patch
;; applies clean.
;;
;; So this pin is load-bearing, not just churn control -- if you refresh it,
;; re-check both ends.  To move it:
;;   git fetch --depth 1 origin <commit> && git checkout FETCH_HEAD
;;   grep -E 'wlroots-0|scenefx-0' meson.build
;;   patch -p1 --dry-run --input packages/mango-tag-names.patch
;;   guix hash -x -S nar -H sha256 -f nix-base32 .
(define %mango-commit "3d05901af7c23f6f85f264c3486f59a21be78f04")

(define-public mangowm-git
  (package
    (inherit (@ (mangowm) mangowm-git))
    (version (git-version "0" "0" %mango-commit))
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/mangowm/mango.git")
             (commit %mango-commit)))
       (file-name (git-file-name "mangowm" %mango-commit))
       (sha256
        (base32 "189grsrfqca0k7483vbgafqwfb6cwafk9109vpkcfnjw4m320wyi"))))
    (inputs
     (modify-inputs (package-inputs (@ (mangowm) mangowm-git))
       (replace "wlroots" wlroots-0.20)
       (replace "scenefx" scenefx-0.5)))
    (arguments
     (substitute-keyword-arguments (package-arguments (@ (mangowm) mangowm-git))
       ((#:phases phases)
        #~(modify-phases #$phases
            (add-after 'patch-meson 'add-tag-names
              (lambda _
                (invoke "patch" "-p1" "--input"
                        #$(local-file "mango-tag-names.patch"))))))))))
