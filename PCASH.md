# P.CASH fork

JNA wrapper for the P.CASH desktop QR scanner, published through JitPack as
`com.github.piratecash:openpnp-capture-java:v0.0.30-2-pcash.N`.

- Tag `v0.0.30-2-pcash.N` only after the same tag's release exists in
  [piratecash/openpnp-capture](https://github.com/piratecash/openpnp-capture).
- `jitpack.yml` fetches that release with `scripts/download-openpnp-capture.sh` (manifest and checksums
  verified) and runs `mvn -B install`, whose `LoadLibraryTest` loads the Linux library.
- Local build: `scripts/download-openpnp-capture.sh <tag> && mvn -B install`.
