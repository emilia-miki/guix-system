(list (channel
       (name 'asahi)
       (url "https://codeberg.org/asahi-guix/channel")
       (branch "main")
       (commit "b9132769b361431e999f7d166d715ef4c6e101d2")
       (introduction
        (make-channel-introduction
         "3eeb493b037bea44f225c4314c5556aa25aff36c"
         (openpgp-fingerprint
          "D226 A339 D8DF 4481 5DDE  0CA0 3DDA 5252 7D2A C199"))))
      (channel
       (name 'nonguix)
       (url "https://gitlab.com/nonguix/nonguix")
       (branch "master")
       (commit "2b2e1002c620ec53115d20c96ecdd2ce7236da25")
       (introduction
        (make-channel-introduction
         "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
         (openpgp-fingerprint
          "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
      (channel
       (name 'tailscale)
       (url "https://github.com/umanwizard/guix-tailscale")
       (branch "main")
       (commit "eac06962d453e6ea9bd59ed1eee18ee77ab104ca")
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
       (commit "22617f2186a1e0c5f27303efac1aa583e5d073c0"))
      (channel
       (name 'mangowm)
       (url "https://github.com/mangowm/mango.git")
       (branch "main")
       (commit "5040bc34536e7b1aeaba5deee4c44fcea66abf3c"))
      (channel
       (name 'guix)
       (url "https://git.guix.gnu.org/guix.git")
       (branch "master")
       (commit "39fa898ce63efad6a320fb1ef2a59f9a6ee258b2")
       (introduction
        (make-channel-introduction
         "9edb3f66fd807b096b48283debdcddccfea34bad"
         (openpgp-fingerprint
          "BBB0 2DDF 2CEA F6A8 0D1D  E643 A2A0 6DF2 A33A 54FA")))))
