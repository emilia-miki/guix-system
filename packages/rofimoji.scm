(define-module (packages rofimoji)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system pyproject)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-xyz))

(define-public rofimoji
  (package
   (name "rofimoji")
   (version "6.7.0")
   (source
    (origin
     (method url-fetch)
     (uri (string-append
           "https://github.com/fdw/rofimoji/archive/refs/tags/"
           version ".tar.gz"))
     (sha256
      (base32 "1hsdczrrj0ck956f8zh2lc0772whm1mwdzbcpwmhkr546s4pslwv"))))
   (build-system pyproject-build-system)
   (arguments
    (list #:tests? #f))
   (native-inputs
    (list python-hatchling))
   (propagated-inputs
    (list python-configargparse))
   (synopsis "Simple character picker using rofi, wofi or dmenu")
   (description
    "Rofimoji is a character picker for rofi, wofi, fuzzel and other
dmenu-compatible launchers.  It comes with a large set of Unicode character
data files and copies the selected character to the clipboard.")
   (home-page "https://github.com/fdw/rofimoji")
   (license license:expat)))
