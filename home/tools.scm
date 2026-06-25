(define-module (home tools)
  #:use-module (gnu home services)
  #:use-module (gnu home services mpv)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu packages mail)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages base)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages curl)
  #:use-module (gnu packages djvu)
  #:use-module (gnu packages dns)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages golang)
  #:use-module (gnu packages golang-apps)
  #:use-module (gnu packages guile-xyz)
  #:use-module (gnu packages image)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages llvm)
  #:use-module (gnu packages markup)
  #:use-module (gnu packages pdf)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-check)
  #:use-module (gnu packages readline)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages rust-apps)
  #:use-module (gnu packages shellutils)
  #:use-module (gnu packages tmux)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages video)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (packages audacity)
  #:use-module (packages claude-code)
  #:use-module (local)
  #:export (%tools-services))

(define-public %tools-services
  (list
   (service home-mpv-service-type
            (make-home-mpv-configuration))

   (simple-service 'dev-packages
                   home-profile-service-type
                   (list
                    ;; shell/system utilities
                    curl tree rlwrap inotify-tools
                    ;; VCS
                    git
                    ;; process/env management
                    direnv tmux
                    ;; search/navigation
                    ripgrep ripgrep-all eza bat fd gitui
                    starship tokei zoxide hyperfine
                    ;; language runtimes & toolchains
                    rust rust-analyzer
                    (list isc-bind "utils")
                    uv patchelf
                    go gopls ruff python
                    ;; build tools
                    gcc-toolchain autoconf automake gnu-make
                    libtool cmake clang pkg-config unzip typst markdown
                    ;; libraries (for development)
                    guile-lib guile-arguments
                    poppler libpng zlib djvulibre djview
                    ;; media processing
                    ffmpeg yt-dlp cava mpv audacity-wayland
                    ;; other
                    claude-code))

   (simple-service 'hydroxide
                   home-shepherd-service-type
                   (list
                    (shepherd-service
                     (provision '(hydroxide-smtp))
                     (start #~(make-forkexec-constructor
                               (list #$(file-append hydroxide "/bin/hydroxide")
                                     "smtp")))
                     (stop #~(make-kill-destructor))
                     (respawn? #t))
                    (shepherd-service
                     (provision '(hydroxide-imap))
                     (start #~(make-forkexec-constructor
                               (list #$(file-append hydroxide "/bin/hydroxide")
                                     "imap")))
                     (stop #~(make-kill-destructor))
                     (respawn? #t))))

   (simple-service 'tools-xdg-config
                   home-xdg-configuration-files-service-type
                   `(("tmux/tmux.conf"
                      ,(local-file "files/tmux.conf"))
                     ("git/ignore"
                      ,(plain-file "gitignore" "**/.claude/\n"))
                     ("git/config"
                      ,(mixed-text-file "gitconfig"
                                        "[user]\n"
                                        "\tname = Emilia Miki\n"
                                        "\temail = " %protonmail-address "\n"
                                        "\n"
                                        "[init]\n"
                                        "\tdefaultBranch = main\n"
                                        "\n"
                                        "[core]\n"
                                        "\texcludesFile = ~/.config/git/ignore\n"))))))
