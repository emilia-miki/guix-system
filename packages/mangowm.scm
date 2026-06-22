(define-module (packages mangowm)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix build-system meson)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages admin)       ; seatd
  #:use-module (gnu packages javascript)   ; cjson
  #:use-module (gnu packages freedesktop) ; wayland, wayland-protocols, libliftoff
  #:use-module (gnu packages gtk)         ; pango (pangocairo) — missing in channel
  #:use-module (gnu packages image)       ; pixman
  #:use-module (gnu packages linux)       ; libinput
  #:use-module (gnu packages pcre)        ; pcre2
  #:use-module (gnu packages pciutils)    ; hwdata
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages wm)          ; wlroots-0.19, scenefx, libdisplay-info
  #:use-module (gnu packages xdisorg)     ; libdrm, libxkbcommon
  #:use-module (gnu packages xorg)        ; libxcb, xcb-util-wm
  #:export (mangowm-git))

(define-public mangowm-git
  (package
    (name "mangowm")
    (version "0.14.4")
    (source
     (origin
       (method url-fetch)
       (uri "https://github.com/mangowm/mango/archive/refs/heads/main.tar.gz")
       (sha256
        (base32 "0dkjd02x7r788xfrah7hpn5l71q69qmchgk82gbn1h8zr8g3jj59"))))
    (build-system meson-build-system)
    (arguments
     (list
      #:configure-flags
      #~(list (string-append "-Dsysconfdir=" #$output "/etc"))
      #:phases
      #~(modify-phases %standard-phases
          (add-before 'configure 'patch-meson
            (lambda _
              (substitute* "meson.build"
                (("is_nixos = false")
                 "is_nixos = true")
                (("'-DSYSCONFDIR=\\\"@0@\\\"'.format\\('/etc'\\)")
                 "'-DSYSCONFDIR=\"@0@\"'.format(sysconfdir)"))))
          (add-after 'patch-meson 'fix-tab-bar-hidpi
            (lambda _
              ;; Both callers of mango_tab_bar_node_update hardcode scale=1.0,
              ;; causing blurry tab bar text on HiDPI displays.  Use the actual
              ;; output scale instead.
              (substitute* "src/action/client.h"
                (("mango_tab_bar_node_update\\(c->tab_bar_node, client_get_title\\(c\\), 1\\.0\\);")
                 "mango_tab_bar_node_update(c->tab_bar_node, client_get_title(c), c->mon ? c->mon->wlr_output->scale : 1.0f);"))
              (substitute* "src/mango.c"
                (("mango_tab_bar_node_update\\(c->tab_bar_node, title, 1\\.0\\);")
                 "mango_tab_bar_node_update(c->tab_bar_node, title, c->mon ? c->mon->wlr_output->scale : 1.0f);")))))))
    (inputs
     (list wayland
           libinput
           libdrm
           libxkbcommon
           pixman
           pango              ; pangocairo — missing in upstream channel package
           libdisplay-info
           libliftoff
           hwdata
           seatd
           pcre2
           cjson
           libxcb
           xcb-util-wm
           wlroots-0.19
           scenefx))
    (native-inputs
     (list pkg-config wayland-protocols))
    (home-page "https://github.com/mangowm/mango")
    (synopsis "Wayland compositor based on wlroots and scenefx")
    (description
     "MangoWM is a modern, lightweight Wayland compositor built on dwl, offering
window effects via scenefx, multiple layouts, IPC, hot-reload config, and
excellent XWayland support.")
    (license (list license:gpl3 license:expat license:cc0))))
