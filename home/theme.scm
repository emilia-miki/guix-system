(define-module (home theme)
  #:use-module (gnu home services)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages kde-frameworks)
  #:use-module (gnu packages qt)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (packages rose-pine-gtk)
  #:use-module (packages rose-pine-kvantum)
  #:export (%theme-services))

(define %gtk-settings
  "\
[Settings]
gtk-application-prefer-dark-theme=1
gtk-theme-name=rose-pine-gtk
gtk-cursor-theme-name=Adwaita
gtk-cursor-theme-size=24
gtk-icon-theme-name=rose-pine-icons
")

(define-public %theme-services
  (list
   (simple-service 'theme-packages
                   home-profile-service-type
                   (list rose-pine-gtk rose-pine-kvantum kvantum dconf))

   ;; KDE color scheme file — without this, ColorScheme=RosePine in kdeglobals
   ;; causes KDE (when KDE_FULL_SESSION=true) to fall back to internal defaults
   ;; that have a distinct BackgroundAlternate, producing zebra rows in the
   ;; Places panel.  We provide the file so KDE loads our explicit values.
   (simple-service 'rose-pine-color-scheme
                   home-files-service-type
                   `((".local/share/color-schemes/RosePine.colors"
                      ,(plain-file "RosePine.colors"
                                   "\
[ColorEffects:Disabled]
Color=56,56,56
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=112,111,110
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=30,28,42
BackgroundNormal=30,28,42
DecorationFocus=235,111,146
DecorationHover=235,111,146
ForegroundActive=235,188,186
ForegroundInactive=144,140,170
ForegroundLink=156,207,216
ForegroundNegative=235,111,146
ForegroundNeutral=246,193,119
ForegroundNormal=224,222,244
ForegroundPositive=156,207,216
ForegroundVisited=196,167,231

[Colors:Complementary]
BackgroundAlternate=25,23,36
BackgroundNormal=25,23,36
DecorationFocus=235,111,146
DecorationHover=235,111,146
ForegroundActive=235,188,186
ForegroundInactive=144,140,170
ForegroundLink=156,207,216
ForegroundNegative=235,111,146
ForegroundNeutral=246,193,119
ForegroundNormal=224,222,244
ForegroundPositive=156,207,216
ForegroundVisited=196,167,231

[Colors:Header]
BackgroundAlternate=25,23,36
BackgroundNormal=25,23,36
DecorationFocus=235,111,146
DecorationHover=235,111,146
ForegroundActive=235,188,186
ForegroundInactive=144,140,170
ForegroundLink=156,207,216
ForegroundNegative=235,111,146
ForegroundNeutral=246,193,119
ForegroundNormal=224,222,244
ForegroundPositive=156,207,216
ForegroundVisited=196,167,231

[Colors:Selection]
BackgroundAlternate=64,60,100
BackgroundNormal=64,60,100
DecorationFocus=235,111,146
DecorationHover=235,111,146
ForegroundActive=235,188,186
ForegroundInactive=144,140,170
ForegroundLink=156,207,216
ForegroundNegative=235,111,146
ForegroundNeutral=246,193,119
ForegroundNormal=224,222,244
ForegroundPositive=156,207,216
ForegroundVisited=196,167,231

[Colors:Tooltip]
BackgroundAlternate=30,28,42
BackgroundNormal=30,28,42
DecorationFocus=235,111,146
DecorationHover=235,111,146
ForegroundActive=235,188,186
ForegroundInactive=144,140,170
ForegroundLink=156,207,216
ForegroundNegative=235,111,146
ForegroundNeutral=246,193,119
ForegroundNormal=224,222,244
ForegroundPositive=156,207,216
ForegroundVisited=196,167,231

[Colors:View]
BackgroundAlternate=25,23,36
BackgroundNormal=25,23,36
DecorationFocus=235,111,146
DecorationHover=235,111,146
ForegroundActive=235,188,186
ForegroundInactive=144,140,170
ForegroundLink=156,207,216
ForegroundNegative=235,111,146
ForegroundNeutral=246,193,119
ForegroundNormal=224,222,244
ForegroundPositive=156,207,216
ForegroundVisited=196,167,231

[Colors:Window]
BackgroundAlternate=25,23,36
BackgroundNormal=25,23,36
DecorationFocus=235,111,146
DecorationHover=235,111,146
ForegroundActive=235,188,186
ForegroundInactive=144,140,170
ForegroundLink=156,207,216
ForegroundNegative=235,111,146
ForegroundNeutral=246,193,119
ForegroundNormal=224,222,244
ForegroundPositive=156,207,216
ForegroundVisited=196,167,231

[General]
ColorSchemeVersion=1
Name=RosePine
Shade SortByName=true
shadeSortByName=true

[WM]
activeBackground=29,23,31
activeForeground=224,222,244
inactiveBackground=25,23,36
inactiveForeground=110,106,134
"))))

   (simple-service 'theme-env
                   home-environment-variables-service-type
                   '(("QT_QPA_PLATFORMTHEME"  . "qt6ct")
                     ("QT_PLUGIN_PATH"        . "$HOME/.guix-home/profile/lib:$HOME/.guix-home/profile/lib/qt6/plugins:/run/current-system/profile/lib/qt6/plugins")
                     ("ADW_DEBUG_COLOR_SCHEME" . "prefer-dark")
                     ("XCURSOR_THEME" . "Adwaita")
                     ("XCURSOR_SIZE"  . "24")
                     ("QT_SCALE_FACTOR_ROUNDING_POLICY" . "PassThrough")))

   (simple-service 'gtk-files
                   home-files-service-type
                   `((".config/gtk-3.0/settings.ini"
                      ,(plain-file "gtk-settings.ini" %gtk-settings))
                     (".config/gtk-4.0/settings.ini"
                      ,(plain-file "gtk-settings.ini" %gtk-settings))
                     ;; Rose Pine GTK4 CSS extended with CSS custom properties.
                     ;; Libadwaita reads --window-bg-color etc. (CSS custom properties)
                     ;; which respect cascade order (user priority 800 > adwaita's 600).
                     ;; @define-color alone is insufficient because libadwaita overwrites
                     ;; those in load order regardless of priority.
                     (".config/gtk-4.0/gtk.css"
                      ,(computed-file "gtk4.css"
                                      #~(begin
                                          (use-modules (ice-9 textual-ports))
                                          (call-with-output-file #$output
                                            (lambda (port)
                                              (display
                                               (call-with-input-file
                                                   #$(file-append rose-pine-gtk
                                                                  "/share/themes/rose-pine-gtk/gtk-4.0/gtk.css")
                                                   get-string-all)
                                               port)
                                              (display "\

/* CSS custom properties for libadwaita — these respect cascade order unlike @define-color */
:root {
  --window-bg-color: #191724;
  --window-fg-color: #e0def4;
  --view-bg-color: #1f1d2e;
  --view-fg-color: #e0def4;
  --headerbar-bg-color: #191724;
  --headerbar-fg-color: #e0def4;
  --headerbar-border-color: #e0def4;
  --headerbar-backdrop-color: #191724;
  --headerbar-shade-color: #191724;
  --headerbar-darker-shade-color: #0d0c14;
  --sidebar-bg-color: #1f1d2e;
  --sidebar-fg-color: #e0def4;
  --sidebar-backdrop-color: #1f1d2e;
  --sidebar-border-color: #26233a;
  --sidebar-shade-color: #191724;
  --secondary-sidebar-bg-color: #26233a;
  --secondary-sidebar-fg-color: #e0def4;
  --secondary-sidebar-backdrop-color: #26233a;
  --secondary-sidebar-border-color: #26233a;
  --secondary-sidebar-shade-color: #1f1d2e;
  --card-bg-color: #26233a;
  --card-fg-color: #e0def4;
  --card-shade-color: #1f1d2e;
  --dialog-bg-color: #26233a;
  --dialog-fg-color: #e0def4;
  --popover-bg-color: #26233a;
  --popover-fg-color: #e0def4;
  --popover-shade-color: #1f1d2e;
  --thumbnail-bg-color: #403d52;
  --thumbnail-fg-color: #e0def4;
  --shade-color: #191724;
  --scrollbar-outline-color: #0d0c14;
  --accent-bg-color: #c4a7e7;
  --accent-fg-color: #191724;
  --accent-color: #c4a7e7;
  --destructive-bg-color: #eb6f92;
  --destructive-fg-color: #191724;
  --destructive-color: #eb6f92;
  --success-bg-color: #9ccfd8;
  --success-fg-color: #191724;
  --success-color: #9ccfd8;
  --warning-bg-color: #f6c177;
  --warning-fg-color: #191724;
  --warning-color: #f6c177;
  --error-bg-color: #eb6f92;
  --error-fg-color: #191724;
  --error-color: #eb6f92;
}
" port))))))))

   (simple-service 'desktop-interface-settings
                   home-activation-service-type
                   #~(let ((dconf #$(file-append dconf "/bin/dconf")))
                       (system* dconf "write"
                                "/org/gnome/desktop/interface/gtk-theme"
                                "'rose-pine-gtk'")
                       (system* dconf "write"
                                "/org/gnome/desktop/interface/icon-theme"
                                "'rose-pine-icons'")
                       (system* dconf "write"
                                "/org/gnome/desktop/interface/color-scheme"
                                "'prefer-dark'")
                       (system* dconf "write"
                                "/org/gnome/desktop/interface/cursor-theme"
                                "'Adwaita'")
                       (system* dconf "write"
                                "/org/gnome/desktop/interface/cursor-size"
                                "24")))

   (simple-service 'kde-app-theme-config
                   home-xdg-configuration-files-service-type
                   `(("Kvantum/kvantum.kvconfig"
                      ,(plain-file "kvantum.kvconfig"
                                   "\
[General]
theme=rose-pine-love
respect_DE=false
"))
                     ;; Route XDG Settings portal to gtk so Qt 6.5+ reads color-scheme from dconf.
                     ("xdg-desktop-portal/portals.conf"
                      ,(plain-file "portals.conf"
                                   "\
[preferred]
default=wlr
org.freedesktop.impl.portal.Settings=gtk
org.freedesktop.impl.portal.FileChooser=gtk
"))

                     ;; User Kvantum theme override: bump layout_margin 4→6 and
                     ;; layout_spacing 2→4 so form layouts in dialogs don't overlap.
                     ;; Kvantum prefers ~/.config/Kvantum/<name>/ over system themes.
                     ("Kvantum/rose-pine-love/rose-pine-love.svg"
                      ,(computed-file "rose-pine-love.svg"
                                      #~(begin
                                          (use-modules (ice-9 textual-ports) (ice-9 regex))
                                          (define src
                                            (call-with-input-file
                                                #$(file-append rose-pine-kvantum
                                                               "/share/Kvantum/rose-pine-love/rose-pine-love.svg")
                                              get-string-all))
                                          (call-with-output-file #$output
                                            (lambda (port)
                                              (display
                                               (regexp-substitute/global
                                                #f "#1f1d2e"
                                                src
                                                'pre "#191724" 'post)
                                               port))))))
                     ("Kvantum/rose-pine-love/rose-pine-love.kvconfig"
                      ,(computed-file "rose-pine-love.kvconfig"
                                      #~(begin
                                          (use-modules (ice-9 textual-ports) (ice-9 regex))
                                          (define src
                                            (call-with-input-file
                                                #$(file-append rose-pine-kvantum
                                                               "/share/Kvantum/rose-pine-love/rose-pine-love.kvconfig")
                                              get-string-all))
                                          (call-with-output-file #$output
                                            (lambda (port)
                                              (display
                                               (regexp-substitute/global
                                                #f "layout_margin=4"
                                                (regexp-substitute/global
                                                 #f "layout_spacing=2"
                                                 (regexp-substitute/global
                                                  #f "window\\.color=#1f1d2e"
                                                  src
                                                  'pre "window.color=#191724" 'post)
                                                 'pre "layout_spacing=4" 'post)
                                                'pre "layout_margin=6" 'post)
                                               port))))))

                     ("kdeglobals"
                      ,(plain-file "kdeglobals"
                                   "\
[KDE]
widgetStyle=kvantum

[General]
ColorScheme=RosePine

[Icons]
Theme=rose-pine-icons
FallbackTheme=breeze-dark

[Colors:Window]
BackgroundNormal=25,23,36
ForegroundNormal=224,222,244
BackgroundAlternate=25,23,36

[Colors:View]
BackgroundNormal=25,23,36
ForegroundNormal=224,222,244
BackgroundAlternate=25,23,36
ForegroundLink=156,207,216
ForegroundVisited=196,167,231

[Colors:Button]
BackgroundNormal=30,28,42
ForegroundNormal=224,222,244

[Colors:Selection]
BackgroundNormal=64,60,100
ForegroundNormal=224,222,244

[Colors:Tooltip]
BackgroundNormal=30,28,42
ForegroundNormal=224,222,244

[Colors:Header]
BackgroundNormal=25,23,36
ForegroundNormal=224,222,244
BackgroundAlternate=25,23,36

[Colors:Complementary]
BackgroundNormal=25,23,36
ForegroundNormal=224,222,244
BackgroundAlternate=25,23,36
"))))

   (simple-service 'qt6ct-conf
                   home-activation-service-type
                   #~(begin
                       (use-modules (guix build utils))
                       (let* ((home      (getenv "HOME"))
                              (conf-path (string-append home "/.config/qt6ct/qt6ct.conf"))
                              (qss-dir   (string-append home "/.config/qt6ct/qss"))
                              (qss-path  (string-append qss-dir "/kde-compat.qss")))
                         (mkdir-p qss-dir)
                         (call-with-output-file qss-path
                           (lambda (port)
                             (display "\
/* QFormLayout rows in KDE settings dialogs overlap at 1.5x Wayland fractional
   scale because QLabel::heightForWidth() underestimates height when the form
   width is not yet known. Adding padding inflates each label's allocated size
   enough to prevent rows from landing on top of each other. */
QDialog QLabel {
    padding-top: 4px;
    padding-bottom: 4px;
}

/* Force KDE page dialogs (Configure Dolphin etc.) to be tall enough for all
   form rows to receive their full computed height without compression. */
KPageDialog {
    min-height: 700px;
}

/* Force QListView alternate-row color to match the base color so KFilePlacesView
   (Dolphin Places panel) shows no zebra stripes. Without KDE_FULL_SESSION the
   [Colors:Header] BackgroundAlternate falls back to a computed shade that differs
   from #191724, producing a visible stripe on section-header rows. */
QListView {
    alternate-background-color: #191724;
    background-color: #191724;
}
" port)))
                         (call-with-output-file conf-path
                           (lambda (port)
                             (display "[Appearance]\n" port)
                             (display "custom_palette=false\n" port)
                             (display "icon_theme=rose-pine-icons\n" port)
                             (display "standard_dialogs=default\n" port)
                             (display "style=kvantum\n" port)
                             (display "\n[Fonts]\n" port)
                             (display "fixed=\"Noto Sans,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1\"\n" port)
                             (display "general=\"Noto Sans,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1\"\n" port)
                             (display "\n[Interface]\n" port)
                             (display "activate_item_on_single_click=1\n" port)
                             (display "buttonbox_layout=0\n" port)
                             (display "cursor_flash_time=1000\n" port)
                             (display "dialog_buttons_have_icons=1\n" port)
                             (display "double_click_interval=400\n" port)
                             (display "gui_effects=@Invalid()\n" port)
                             (display "keyboard_scheme=2\n" port)
                             (display "menus_have_icons=true\n" port)
                             (display "show_shortcuts_in_context_menus=true\n" port)
                             (display (string-append "stylesheets=" qss-path "\n") port)
                             (display "toolbutton_style=4\n" port)
                             (display "underline_shortcut=1\n" port)
                             (display "wheel_scroll_lines=3\n" port)
                             (display "\n[Troubleshooting]\n" port)
                             (display "ignored_applications=@Invalid()\n" port))))))

   (simple-service 'rebuild-kde-cache
                   home-activation-service-type
                   #~(let ((home (getenv "HOME")))
                       (setenv "XDG_DATA_DIRS"
                               (string-append home "/.guix-home/profile/share"
                                              ":/run/current-system/profile/share"))
                       (system* #$(file-append kservice "/bin/kbuildsycoca6")
                                "--noincremental")))))
