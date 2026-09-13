(define-module (packages anydesk)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages polkit)
  #:use-module (gnu packages pulseaudio)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  #:use-module (nongnu packages anydesk))

;; AnyDesk ships aarch64 binaries only under the "rpi" download path, as a
;; plain tarball rather than the .deb used for x86_64.  The layout has no
;; "usr/" prefix, and 8.x links against GTK 3 where the 6.x deb used GTK 2, so
;; the source, inputs and both plans are replaced wholesale.
(define-public anydesk-arm64
  (package
    (inherit anydesk)
    (version "8.0.4")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://download.anydesk.com/rpi/anydesk-"
                                  version "-arm64.tar.gz"))
              (sha256
               (base32
                "0zc1mvx4pp98f51cgglnm28iarz3638648py46c528j50xapamac"))))
    (supported-systems '("aarch64-linux"))
    (arguments
     `(#:validate-runpath? #f
       #:strip-binaries? #f              ;as upstream: stripping breaks it
       #:patchelf-plan
       `(("anydesk" ("alsa-lib"
                     "cairo"
                     "dbus"
                     "eudev"
                     "fontconfig"
                     "freetype"
                     "gcc:lib"
                     "gdk-pixbuf"
                     "glib"
                     "gtk+"
                     "libepoxy"
                     "libx11"
                     "libxcb"
                     "libxdamage"
                     "libxext"
                     "libxfixes"
                     "libxi"
                     "libxkbcommon"
                     "libxkbfile"
                     "libxrandr"
                     "libxrender"
                     "libxtst"
                     "mesa"
                     "pango"
                     "polkit"
                     "pulseaudio"
                     "wayland")))
       #:install-plan
       `(("anydesk" "/bin/")
         ("polkit-1/com.anydesk.anydesk.policy" "/etc/polkit-1/actions/")
         ;; No trailing slash: copy the tree *as* share/icons, rather than
         ;; nesting it at share/icons/icons.
         ("icons" "/share/icons"))
       #:phases
       (modify-phases %standard-phases
         (add-after 'install 'install-desktop-entry
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (applications (string-append out "/share/applications")))
               (substitute* "anydesk.desktop"
                 (("^Exec=.*")
                  (string-append "Exec=" out "/bin/anydesk %u\n"))
                 (("^Icon=.*") "Icon=anydesk\n"))
               (install-file "anydesk.desktop" applications)))))))
    (inputs
     ;; Labels are load-bearing here: #:patchelf-plan refers to inputs by name.
     ;; libasound, libpulse, libGL/libEGL and libvulkan are dlopen'd rather
     ;; than NEEDED, so they must still land in the RUNPATH.
     `(("alsa-lib" ,alsa-lib)
       ("cairo" ,cairo)
       ("dbus" ,dbus)
       ("eudev" ,eudev)
       ("fontconfig" ,fontconfig)
       ("freetype" ,freetype)
       ("gcc:lib" ,gcc "lib")
       ("gdk-pixbuf" ,gdk-pixbuf)
       ("glib" ,glib)
       ("gtk+" ,gtk+)
       ("libepoxy" ,libepoxy)
       ("libx11" ,libx11)
       ("libxcb" ,libxcb)
       ("libxdamage" ,libxdamage)
       ("libxext" ,libxext)
       ("libxfixes" ,libxfixes)
       ("libxi" ,libxi)
       ("libxkbcommon" ,libxkbcommon)
       ("libxkbfile" ,libxkbfile)
       ("libxrandr" ,libxrandr)
       ("libxrender" ,libxrender)
       ("libxtst" ,libxtst)
       ("mesa" ,mesa)
       ("pango" ,pango)
       ("polkit" ,polkit)
       ("pulseaudio" ,pulseaudio)
       ("wayland" ,wayland)))))
