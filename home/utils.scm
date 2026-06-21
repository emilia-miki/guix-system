(define-module (home utils)
  #:use-module (gnu home services)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:export (symlink-home-service))

(define (symlink-home-service name link target)
  "Return a home activation service that symlinks $HOME/LINK -> $HOME/TARGET,
creating the parent directory if needed."
  (let ((dir (let ((i (string-rindex link #\/)))
               (if i (substring link 0 i) ""))))
    (simple-service name
                    home-activation-service-type
                    #~(let* ((home   (getenv "HOME"))
                             (link   (string-append home #$link))
                             (target (string-append home #$target)))
                        (mkdir-p (string-append home #$dir))
                        (catch 'system-error
                          (lambda () (delete-file link))
                          (const #f))
                        (symlink target link)))))
