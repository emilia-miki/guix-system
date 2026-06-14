(define-module (packages ollama)
  #:use-module (ollama-bin)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix build-system trivial)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages elf)
  #:use-module (gnu packages gcc))

(define-public ollama-linux-arm64
  (package
   (inherit ollama-linux-amd64)
   (name "ollama-linux-arm64")
   (version "0.30.8")
   (source
    (origin
     (method url-fetch)
     (uri "https://github.com/ollama/ollama/releases/download/v0.30.8/ollama-linux-arm64.tar.zst")
     (sha256
      (base32 "1235sddkw1xpcsh10xywz5sg5rdra2g6r9xlic95a10b9f9nz2k6"))))
   (build-system trivial-build-system)
   (native-inputs (list tar zstd patchelf))
   (inputs (list glibc (list gcc "lib")))
   (arguments
    (list #:modules '((guix build utils))
          #:builder
          #~(begin
              (use-modules (guix build utils))
              (setenv "PATH" (string-append
                              #$tar "/bin:"
                              #$zstd "/bin:"
                              #$patchelf "/bin"))
              (let* ((out      #$output)
                     (bin      (string-append out "/bin"))
                     (lib-dir  (string-append out "/lib/ollama"))
                     (binary   (string-append bin "/ollama.real"))
                     (lserver  (string-append lib-dir "/llama-server"))
                     (wrapper  (string-append bin "/ollama"))
                     (glibc    #$glibc)
                     (gcc-lib  (assoc-ref %build-inputs "gcc"))
                     (interp   (string-append glibc "/lib/ld-linux-aarch64.so.1"))
                     (rpath    (string-append lib-dir ":" glibc "/lib:" gcc-lib "/lib")))
                (mkdir-p bin)
                ;; Extract full tarball (bin/ and lib/ollama/)
                (invoke "tar" "--zstd" "-xf" #$source "-C" out)
                ;; Rename main binary, create real binary slot
                (rename-file (string-append bin "/ollama") binary)
                ;; Patchelf main binary
                (chmod binary #o755)
                (invoke "patchelf" "--set-interpreter" interp binary)
                (invoke "patchelf" "--set-rpath" rpath binary)
                ;; Patchelf llama-server
                (chmod lserver #o755)
                (invoke "patchelf" "--set-interpreter" interp lserver)
                (invoke "patchelf" "--set-rpath" rpath lserver)
                ;; Wrapper sets LD_LIBRARY_PATH for bundled libs + system libs
                (call-with-output-file wrapper
                  (lambda (port)
                    (format port "#!/bin/sh\n")
                    (format port "export LD_LIBRARY_PATH=~a:~a/lib:~a/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}\n"
                            lib-dir glibc gcc-lib)
                    (format port "exec ~a \"$@\"\n" binary)))
                (chmod wrapper #o755)))))
   (supported-systems (list "aarch64-linux"))))
