(define-module (packages noctalia-patched)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (noctalia)
  #:export (noctalia-patched))

;; Show mango tag names -- the "name" field that mango-tag-names.patch adds to
;; the IPC tag JSON -- as workspace names, instead of the bare tag index.
(define-public noctalia-patched
  (package
    (inherit noctalia-git)
    (name "noctalia-patched")
    (arguments
     (substitute-keyword-arguments (package-arguments noctalia-git)
       ((#:phases phases)
        #~(modify-phases #$phases
            (add-after 'prepare-for-build 'add-mango-tag-names
              (lambda _
                (invoke "patch" "-p1" "--input"
                        #$(local-file "noctalia-mango-tag-names.patch"))))))))))
