(define-module (home mango)
  #:use-module (gnu home services)
  #:use-module (gnu home services fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gnome-xyz)
  #:use-module (gnu packages image)
  #:use-module (gnu packages kde-frameworks)
  #:use-module (gnu packages kde-plasma)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages lxqt)
  #:use-module (gnu packages music)
  #:use-module (gnu packages polkit)
  #:use-module (gnu packages qt)
  #:use-module (packages qt6ct-kde)
  #:use-module (packages mangowm)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (packages noctalia-patched)
  #:use-module (packages rofimoji)
  #:use-module (home utils)
  #:export (%mango-services))

(define-public %mango-services
  (list
   (simple-service 'theme-env
                   home-environment-variables-service-type
                   '(("QT_QPA_PLATFORMTHEME"  . "qt6ct")
                     ("QT_PLUGIN_PATH"        . "$HOME/.guix-home/profile/lib:$HOME/.guix-home/profile/lib/qt6/plugins:/run/current-system/profile/lib/qt6/plugins")
                     ("ADW_DEBUG_COLOR_SCHEME" . "prefer-dark")
                     ("XCURSOR_THEME" . "Adwaita")
                     ("XCURSOR_SIZE"  . "24")
                     ("QT_SCALE_FACTOR_ROUNDING_POLICY" . "PassThrough")))

   (simple-service 'desktop-interface-settings
                   home-activation-service-type
                   #~(let ((dconf #$(file-append dconf "/bin/dconf")))
                       (system* dconf "write"
                                "/org/gnome/desktop/interface/gtk-theme"
                                "'adw-gtk3'")
                       (system* dconf "write"
                                "/org/gnome/desktop/interface/color-scheme"
                                "'prefer-dark'")
                       (system* dconf "write"
                                "/org/gnome/desktop/interface/cursor-size"
                                "24")))

   (simple-service 'mango-packages
                   home-profile-service-type
                   (list
                    ;; Core compositor & shell
                    mangowm-git noctalia-patched adw-gtk3-theme qt6ct-kde brightnessctl
                    ;; Terminal
                    foot
                    ;; PolicyKit agent
                    polkit-gnome
                    ;; Portals (screen sharing, file pickers)
                    xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk
                    ;; Audio
                    pavucontrol-qt
                    ;; Notifications library
                    libnotify
                    ;; Qt theming
                    qtsvg font-nerd-symbols breeze breeze-icons qt5ct qt6ct-kde
                    ;; Cursor & media keys
                    adwaita-icon-theme playerctl
                    ;; Emoji / character picker
                    rofimoji wofi
                    ;; Color picker
                    hyprpicker
                    ;; Fonts
                    font-sarasa-gothic
                    font-google-noto
                    font-google-noto-emoji
                    font-gnu-unifont))

   (simple-service 'mango-fontconfig
                   home-fontconfig-service-type
                   (list
                    '(match (@ (target "pattern"))
                       (test (@ (name "family") (compare "eq"))
                             (string "monospace"))
                       (edit (@ (name "family") (mode "prepend") (binding "strong"))
                             (string "Sarasa Term J")))

                    '(match (@ (target "pattern"))
                       (test (@ (name "family") (compare "eq"))
                             (string "sans-serif"))
                       (edit (@ (name "family") (mode "prepend") (binding "strong"))
                             (string "Sarasa UI J")))

                    '(match (@ (target "pattern"))
                       (test (@ (name "family") (compare "eq"))
                             (string "serif"))
                       (edit (@ (name "family") (mode "prepend") (binding "strong"))
                             (string "Sarasa Gothic J")))

                    '(match (@ (target "font"))
                       (test (@ (name "family") (compare "contains"))
                             (string "Sarasa"))
                       (edit (@ (name "spacing") (mode "assign"))
                             (int 100)))

                    '(match (@ (target "font"))
                       (test (@ (name "family") (compare "eq"))
                             (string "Noto Color Emoji"))
                       (edit (@ (name "lang") (mode "assign"))
                             (langset)))

                    '(match (@ (target "pattern"))
                       (edit (@ (name "family") (mode "append_last") (binding "weak"))
                             (string "Noto Sans")
                             (string "Noto Color Emoji")
                             (string "Symbols Nerd Font Mono")
                             (string "Unifont")))))

   (simple-service 'mango-xdg-config
                   home-xdg-configuration-files-service-type
                   `(("rofimoji.rc"
                      ,(plain-file "rofimoji.rc"
                                   "\
selector = wofi
selector-args = --columns 8
action = copy
skin-tone = light
"))))

   (symlink-home-service 'mango-config-symlink
                         "/.config/mango/config.conf"
                         "/Projects/guix-system/home/files/mango-config")

   (symlink-home-service 'sway-config-symlink
                         "/.config/sway/config"
                         "/Projects/guix-system/home/files/sway-config")

   (symlink-home-service 'foot-config-symlink
                         "/.config/foot/foot.ini"
                         "/Projects/guix-system/home/files/foot.ini")

   (symlink-home-service 'noctalia-config-symlink
                         "/.config/noctalia/config.toml"
                         "/Projects/guix-system/home/files/noctalia-config.toml")

   (simple-service 'qt6ct-color-scheme
                   home-activation-service-type
                   #~(begin
                       (use-modules (ice-9 textual-ports))
                       (let* ((home  (getenv "HOME"))
                              (conf  (string-append home "/.config/qt6ct/qt6ct.conf"))
                              (value (string-append home "/.local/share/color-schemes/noctalia.colors"))
                              (entry (string-append "color_scheme_path=" value)))
                         (when (file-exists? conf)
                           (let* ((lines    (string-split
                                             (call-with-input-file conf get-string-all)
                                             #\newline))
                                  (has-key? (let lp ((ls lines))
                                              (and (pair? ls)
                                                   (or (string-prefix? "color_scheme_path=" (car ls))
                                                       (lp (cdr ls))))))
                                  (new-lines
                                   (if has-key?
                                       (map (lambda (l)
                                              (if (string-prefix? "color_scheme_path=" l) entry l))
                                            lines)
                                       (let lp ((ls lines) (acc '()))
                                         (if (null? ls)
                                             (reverse acc)
                                             (let ((l (car ls)))
                                               (if (string=? l "[Appearance]")
                                                   (lp (cdr ls) (cons entry (cons l acc)))
                                                   (lp (cdr ls) (cons l acc)))))))))
                             (call-with-output-file conf
                               (lambda (port)
                                 (display (string-join new-lines "\n") port))))))))))
