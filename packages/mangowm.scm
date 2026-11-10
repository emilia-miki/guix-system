(define-module (packages mangowm)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (mangowm)
  #:export (mangowm-git))

;; Tag names (tag_rule=id:N,name:X) and `mmsg rename tag <index> <name>'.  This
;; is https://github.com/mangowm/mango/pull/1092 (~/Projects/xxx/mango, branch
;; feat/add-tag-custom-names) ported to mango's split config source layout.
;; The channel package builds straight from the channel checkout, so the patch
;; only has to apply at the mangowm commit pinned in channels.scm; re-port it
;; when moving that pin.
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
