(define-module (packages qt6ct-kde)
  #:use-module (gnu packages kde-frameworks)
  #:use-module (gnu packages qt)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:export (qt6ct-kde))

(define-public qt6ct-kde
  (package
    (inherit qt6ct)
    (name "qt6ct-kde")
    (source
     (origin
       (inherit (package-source qt6ct))
       (patches (list (local-file "qt6ct-shenanigans.patch")))))
    (inputs
     (modify-inputs (package-inputs qt6ct)
       (append kcolorscheme kconfig kiconthemes qqc2-desktop-style)))
    (synopsis "Qt6 Configuration Tool, patched to work correctly with KDE applications")
    (description "qt6ct-kde is qt6ct with a patch that adds KDE framework
integration: KColorScheme support for .colors palette files, KIconEngine for
correct monochrome icon colours in KDE application toolbars, and
qqc2-desktop-style as the default QtQuick Controls style.")))
