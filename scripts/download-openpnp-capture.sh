#!/bin/bash
# Fetches the prebuilt natives of a piratecash/openpnp-capture release into openpnp-capture/binaries/.
# FETCH_ATTEMPTS / FETCH_DELAY (seconds) wait for a release whose build matrix is still running.
set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: download-openpnp-capture.sh <release tag>" >&2
    exit 1
fi

TAG="$1"
BASE="https://github.com/piratecash/openpnp-capture/releases/download/$TAG"
ARCHIVES="openpnp-capture-linux-x64.tar.gz openpnp-capture-macos-arm64.tar.gz openpnp-capture-windows-x64.tar.gz"
BINARIES="darwin-aarch64/libopenpnp-capture.dylib linux-x86-64/libopenpnp-capture.so win32-x86-64/openpnp-capture.dll"
ATTEMPTS="${FETCH_ATTEMPTS:-1}"
DELAY="${FETCH_DELAY:-45}"

cd "$(dirname "$0")/.."
DOWNLOAD="$(mktemp -d)"
trap 'rm -rf "$DOWNLOAD"' EXIT

fetch() {
    local i
    for ((i = 1; i <= ATTEMPTS; i++)); do
        if curl -fsSL -o "$DOWNLOAD/$1" "$BASE/$1"; then
            return 0
        fi
        if [ "$i" -lt "$ATTEMPTS" ]; then
            echo "waiting for $1 of $TAG ($i/$ATTEMPTS)" >&2
            sleep "$DELAY"
        fi
    done
    echo "$1 is not available on $TAG" >&2
    return 1
}

for name in natives.sha256 $ARCHIVES; do
    fetch "$name"
done

# Another set means the release published something this script does not know how to install.
diff -u <(printf '%s\n' $ARCHIVES | sort) \
    <(awk '{ sub(/^\*/, "", $2); print $2 }' "$DOWNLOAD/natives.sha256" | sort)

if command -v sha256sum >/dev/null; then
    (cd "$DOWNLOAD" && sha256sum --strict -c natives.sha256)
else
    (cd "$DOWNLOAD" && shasum -a 256 --strict -c natives.sha256)
fi

rm -rf openpnp-capture/binaries
mkdir -p openpnp-capture/binaries
for name in $ARCHIVES; do
    tar -xzf "$DOWNLOAD/$name" -C openpnp-capture/binaries
done

diff -u <(printf '%s\n' $BINARIES | sort) \
    <(cd openpnp-capture/binaries && find . ! -type d | sed 's|^\./||' | sort)
for binary in $BINARIES; do
    [ -s "openpnp-capture/binaries/$binary" ] || { echo "$binary is empty after unpacking" >&2; exit 1; }
done
