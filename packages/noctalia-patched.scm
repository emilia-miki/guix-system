(define-module (packages noctalia-patched)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (guix gexp)
  #:use-module (noctalia)
  #:export (noctalia-patched))

;; noctalia-git with a patch that adds `labels = [...]` support to the
;; workspaces widget.  When set, the list is indexed by the workspace's
;; 1-based numeric ID and the matching string is shown instead of the number.
(define-public noctalia-patched
  (package
    (inherit noctalia-git)
    (name "noctalia-patched")
    (arguments
     (substitute-keyword-arguments (package-arguments noctalia-git)
       ((#:phases phases)
        #~(modify-phases #$phases
            (add-after 'prepare-for-build 'add-workspace-labels
              (lambda _
                (invoke "patch" "-p1" "--input"
                        #$(local-file "noctalia-workspace-labels.patch"))))))))))
