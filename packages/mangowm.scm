(define-module (packages mangowm)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (mangowm)
  #:export (mangowm-git))

;; Tag names (tagrule=id:N,name:X) and `mmsg rename tag <index> <name>'.  This
;; is https://github.com/mangowm/mango/pull/1092 (~/Projects/xxx/mango, branch
;; feat/add-tag-custom-names) ported to mango's post-2026-09-06 source layout.
;; The channel package builds straight from the channel checkout, so the patch
;; must keep applying after each `guix pull'; re-port it when it stops.
(define-public mangowm-git
  (package
    (inherit (@ (mangowm) mangowm-git))
    (arguments
     (substitute-keyword-arguments (package-arguments (@ (mangowm) mangowm-git))
       ((#:phases phases)
        #~(modify-phases #$phases
            (add-after 'patch-meson 'add-tag-names
              (lambda _
                (invoke "patch" "-p1" "--input"
                        #$(local-file "mango-tag-names.patch"))))))))))
