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

(define-public mangowm-git
  (package
    (inherit (@ (mangowm) mangowm-git))
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
