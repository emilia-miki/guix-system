(define-module (home emacs)
  #:use-module (gnu home services)
  #:use-module (gnu home services xdg)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages mail)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages tree-sitter)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (local)
  #:export (%emacs-services))

(define-public %emacs-services
  (list
   (simple-service 'emacs-packages
                   home-profile-service-type
                   (list
                    emacs-pgtk
                    emacs-pdf-tools
                    ;; Mail
                    mu offlineimap3
                    ;; Standard library source for rust-analyzer goto-definition
                    (list rust "rust-src")
                    ;; Tree-sitter grammars
                    tree-sitter-rust
                    tree-sitter-go
                    tree-sitter-javascript
                    tree-sitter-python
                    tree-sitter-bash
                    tree-sitter-markdown
                    tree-sitter-json
                    tree-sitter-toml
                    tree-sitter-typescript
                    tree-sitter-yaml))

   (simple-service 'offlineimaprc
                   home-files-service-type
                   `((".offlineimaprc"
                      ,(mixed-text-file "offlineimaprc"
                                        "[general]\n"
                                        "accounts = ProtonMail\n"
                                        "ui = ttyui\n"
                                        "\n"
                                        "[Account ProtonMail]\n"
                                        "localrepository = ProtonMail-Local\n"
                                        "remoterepository = ProtonMail-Remote\n"
                                        "\n"
                                        "[Repository ProtonMail-Local]\n"
                                        "type = Maildir\n"
                                        "localfolders = ~/.local/mail/protonmail\n"
                                        "\n"
                                        "[Repository ProtonMail-Remote]\n"
                                        "type = IMAP\n"
                                        "remotehost = localhost\n"
                                        "remoteport = 1143\n"
                                        "remoteuser = " %protonmail-address "\n"
                                        "remotepasseval = open(__import__('os').path.expanduser('~/.local/share/hydroxide-bridge-password')).read().strip()\n"
                                        "ssl = no\n"
                                        "auth_mechanisms = LOGIN\n"
                                        "maxconnections = 1\n"
                                        "folderfilter = lambda f: f != 'All Mail'\n"))))

   (simple-service 'emacs-local-mail
                   home-xdg-configuration-files-service-type
                   `(("emacs/local-mail.el"
                      ,(mixed-text-file "local-mail.el"
                                        "(setq user-mail-address \"" %protonmail-address "\")\n"))))

   (simple-service 'emacs-init-symlink
                   home-activation-service-type
                   #~(let* ((home   (getenv "HOME"))
                            (link   (string-append home "/.config/emacs/init.el"))
                            (target (string-append home "/Projects/guix-system/home/files/emacs-init.el")))
                       (mkdir-p (string-append home "/.config/emacs"))
                       (when (file-exists? link)
                         (delete-file link))
                       (symlink target link)))))
