(define-module (packages mangowm)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (mangowm)
  #:export (mangowm-git))

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
                        #$(local-file "mango-tag-names.patch"))))
            (add-after 'add-tag-names 'fix-tab-bar-hidpi
              (lambda _
                (invoke "patch" "-p1" "--input"
                        #$(local-file "mango-tab-bar-hidpi.patch"))))))))))
