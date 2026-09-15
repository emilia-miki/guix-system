(list (channel
       (name 'asahi)
       (url "https://codeberg.org/asahi-guix/channel")
       (branch "main")
       (commit "0a58b24a8448d75ec5570d28ebac2c88ebfbc540")
       (introduction
        (make-channel-introduction
         "3eeb493b037bea44f225c4314c5556aa25aff36c"
         (openpgp-fingerprint
          "D226 A339 D8DF 4481 5DDE  0CA0 3DDA 5252 7D2A C199"))))
      (channel
       (name 'nonguix)
       (url "https://gitlab.com/nonguix/nonguix")
       (branch "master")
       (commit "28a35e22b4d00da89cbf7ac3c824c00f812025ca")
       (introduction
        (make-channel-introduction
         "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
         (openpgp-fingerprint
          "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
      (channel
       (name 'tailscale)
       (url "https://github.com/umanwizard/guix-tailscale")
       (branch "main")
       (commit "4fd673d378f1e82ded518c93624257eaefa5abcc")
       (introduction
        (make-channel-introduction
         "c72e15e84c4a9d199303aa40a81a95939db0cfee"
         (openpgp-fingerprint
          "9E53 FC33 B832 8C74 5E7B  31F7 0226 C10D 7877 B741"))))
      (channel
       (name 'ollama-guix)
       (url "https://codeberg.org/tusharhero/ollama-guix")
       (branch "master")
       (commit "fd6da8ae3bfcf2268302a0644dc2be33e69113af"))
      (channel
       (name 'noctalia)
       (url "https://github.com/noctalia-dev/noctalia")
       (branch "main")
       (commit "c7ae83c3cf7769d90367e22156d432a31c6f7af6"))
      (channel
       (name 'mangowm)
       (url "https://github.com/mangowm/mango.git")
       (branch "main")
       (commit "e2b9ca85bad6af6c3d240a13c9f8eb2a09502663"))
      (channel
       (name 'guix)
       (url "https://git.guix.gnu.org/guix.git")
       (branch "master")
       (commit "d3b5490c2a8d53fcc7cf59ffcb8f1aeb49cd7de2")
       (introduction
        (make-channel-introduction
         "9edb3f66fd807b096b48283debdcddccfea34bad"
         (openpgp-fingerprint
          "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA")))))
