(define-module (packages pinned blender)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (gnu packages graphics)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages xdisorg))

;; Evaluated by the pinned Guix; see (packages pinned).
;;
;; Stock Blender is X11-only; build the Wayland backend instead.  The name
;; differs from stock so the inferior lookup in (packages pinned) is unambiguous.
(define-public blender-wayland
  (package
    (inherit blender)
    (name "blender-wayland")
    (inputs
     (modify-inputs (package-inputs blender)
       (append wayland wayland-protocols libxkbcommon)))
    (arguments
     (substitute-keyword-arguments (package-arguments blender)
       ((#:configure-flags flags)
        #~(append #$flags
                  (list "-DWITH_GHOST_WAYLAND=ON" "-DWITH_GHOST_X11=OFF")))))))
