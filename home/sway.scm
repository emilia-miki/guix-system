(define-module (home sway)
  #:use-module (gnu home services)
  #:use-module (gnu home services fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages image)
  #:use-module (gnu packages kde-frameworks)
  #:use-module (gnu packages kde-plasma)
  #:use-module (gnu packages lxqt)
  #:use-module (gnu packages music)
  #:use-module (gnu packages polkit)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages terminals)
  #:use-module (gnu packages wm)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (home wallpaper)
  #:use-module (packages rofimoji)
  #:export (%sway-services))

(define (executable-file name source)
  (computed-file name
                 #~(begin
                     (copy-file #$source #$output)
                     (chmod #$output #o755))))

(define (with-wallpaper name template)
  (computed-file name
                 #~(begin
                     (use-modules (ice-9 textual-ports) (ice-9 regex))
                     (call-with-output-file #$output
                       (lambda (port)
                         (display
                          (regexp-substitute/global #f "@WALLPAPER@"
                                                    (call-with-input-file #$template get-string-all)
                                                    'pre #$%wallpaper 'post)
                          port))))))

(define-public %sway-services
  (list
   (simple-service 'sway-packages
                   home-profile-service-type
                   (list
                    ;; Core compositor & shell
                    swayidle swaylock swaybg waybar
                    ;; Terminal & launcher
                    foot wofi
                    ;; Notifications
                    mako
                    ;; Screenshots & annotation
                    grim slurp swappy
                    ;; Clipboard
                    wl-clipboard
                    ;; PolicyKit agent
                    polkit-gnome
                    ;; Portals (screen sharing, file pickers)
                    xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk
                    ;; Audio
                    pavucontrol-qt
                    ;; Notifications library
                    libnotify
                    ;; Qt theming
                    qtsvg font-nerd-symbols breeze breeze-icons qt5ct qt6ct
                    ;; Cursor & media keys
                    adwaita-icon-theme playerctl
                    ;; Emoji / character picker
                    rofimoji
                    ;; Color picker
                    hyprpicker
                    ;; Fonts
                    font-sarasa-gothic
                    font-google-noto
                    font-google-noto-emoji
                    font-gnu-unifont))

   (simple-service 'sway-fontconfig
                   home-fontconfig-service-type
                   (list
                    ;; ── Default family assignments ──

                    ;; Sarasa Term J → monospace
                    '(match (@ (target "pattern"))
                       (test (@ (name "family") (compare "eq"))
                             (string "monospace"))
                       (edit (@ (name "family") (mode "prepend") (binding "strong"))
                             (string "Sarasa Term J")))

                    ;; Sarasa UI J → sans-serif
                    '(match (@ (target "pattern"))
                       (test (@ (name "family") (compare "eq"))
                             (string "sans-serif"))
                       (edit (@ (name "family") (mode "prepend") (binding "strong"))
                             (string "Sarasa UI J")))

                    ;; Sarasa Gothic J → serif
                    '(match (@ (target "pattern"))
                       (test (@ (name "family") (compare "eq"))
                             (string "serif"))
                       (edit (@ (name "family") (mode "prepend") (binding "strong"))
                             (string "Sarasa Gothic J")))

                    ;; ── Font metadata fixes ──

                    ;; Mark all Sarasa monospace variants as monospace spacing
                    '(match (@ (target "font"))
                       (test (@ (name "family") (compare "contains"))
                             (string "Sarasa"))
                       (edit (@ (name "spacing") (mode "assign"))
                             (integer 100)))

                    ;; Make Noto Color Emoji available for all languages
                    '(match (@ (target "font"))
                       (test (@ (name "family") (compare "eq"))
                             (string "Noto Color Emoji"))
                       (edit (@ (name "lang") (mode "assign"))
                             (langset)))

                    ;; ── Global fallback chain ──
                    '(match (@ (target "pattern"))
                       (edit (@ (name "family") (mode "append_last") (binding "weak"))
                             (string "Noto Sans")
                             (string "Noto Color Emoji")
                             (string "Symbols Nerd Font Mono")
                             (string "Unifont")))))

   (simple-service 'sway-xdg-config
                   home-xdg-configuration-files-service-type
                   `(("sway/config"
                      ,(with-wallpaper "sway-config" (local-file "files/sway-config")))
                     ("waybar/config.jsonc"
                      ,(local-file "files/waybar-config.jsonc"))
                     ("waybar/style.css"
                      ,(local-file "files/waybar-style.css"))
                     ("waybar/rose-pine.css"
                      ,(local-file "files/waybar-rose-pine.css"))
                     ("waybar/power_menu.xml"
                      ,(local-file "files/waybar-power_menu.xml"))
                     ("waybar/wifimenu"
                      ,(executable-file "wifimenu" (local-file "files/waybar-wifimenu")))
                     ("waybar/wofi-bluetooth"
                      ,(executable-file "wofi-bluetooth" (local-file "files/waybar-wofi-bluetooth")))
                     ("wofi/style.css"
                      ,(plain-file "wofi-style.css"
                                   "\
window {
    margin: 0px;
    background-color: #191724;
    border-radius: 0px;
    border: 2px solid #eb6f92;
    color: #e0def4;
    font-family: 'FiraCode Nerd Font', 'Unifont Upper', 'Noto Sans Symbols 2', 'Noto Sans Symbols', 'Noto Sans';
    font-size: 20px;
}

#input {
    margin: 5px;
    border-radius: 0px;
    border: none;
    color: #eb6f92;
    background-color: #26233a;
}

#inner-box {
    margin: 5px;
    border: none;
    background-color: #26233a;
    color: #e0def4;
    border-radius: 0px;
}

#outer-box {
    margin: 15px;
    border: none;
    background-color: #191724;
}

#scroll {
    margin: 0px;
    border: none;
}

#text {
    margin: 5px;
    border: none;
    color: #e0def4;
}

#entry:selected {
    background-color: #eb6f92;
    color: #191724;
    border-radius: 0px;
    outline: none;
}

#entry:selected * {
    background-color: #eb6f92;
    color: #191724;
    border-radius: 0px;
    outline: none;
}
"))
                     ("rofimoji.rc"
                      ,(plain-file "rofimoji.rc"
                                   "\
selector = wofi
selector-args = --columns 8
action = copy
skin-tone = light
"))
                     ("mako/config"
                      ,(local-file "files/mako-config"))
                     ("foot/foot.ini"
                      ,(local-file "files/foot.ini"))
                     ("swaylock/config"
                      ,(with-wallpaper "swaylock-config" (local-file "files/swaylock-config")))))))

