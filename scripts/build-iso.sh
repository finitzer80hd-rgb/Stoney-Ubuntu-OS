#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
UBUNTU_SUITE="${UBUNTU_SUITE:-noble}"
ARCH="${ARCH:-amd64}"
AUTO_INSTALL_DEPS="${AUTO_INSTALL_DEPS:-1}"
OUT_DIR="$ROOT/out"
WORK_DIR="$ROOT/work"
LOG="$OUT_DIR/build.log"

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo: sudo $0" >&2
  exit 1
fi
if [[ "$ARCH" != "amd64" ]]; then
  echo "This starter is configured for amd64 only (got: $ARCH)." >&2
  exit 2
fi
case "$UBUNTU_SUITE" in
  noble) ;;
  *) echo "This starter currently supports noble only; other Ubuntu suites need validation." >&2; exit 2 ;;
esac

mkdir -p "$OUT_DIR"
exec > >(tee "$LOG") 2>&1
echo "== Stoney Linux ISO build =="
echo "Suite: $UBUNTU_SUITE"
echo "Architecture: $ARCH"
echo "Started: $(date -u +'%Y-%m-%dT%H:%M:%SZ')"
echo "Build host: $(uname -a)"

if [[ "$AUTO_INSTALL_DEPS" == "1" ]]; then
  export DEBIAN_FRONTEND=noninteractive
  apt-get update
  apt-get install -y live-build debootstrap squashfs-tools xorriso grub-pc-bin grub-efi-amd64-bin mtools dosfstools isolinux syslinux-common ca-certificates
fi
for cmd in lb debootstrap mksquashfs xorriso; do
  command -v "$cmd" >/dev/null || {
    echo "Missing required command '$cmd'. Install dependencies or set AUTO_INSTALL_DEPS=1." >&2
    exit 3
  }
done

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
cp -a "$ROOT/config" "$WORK_DIR/config"
cd "$WORK_DIR"

# Note: live-build's Ubuntu mode is version-sensitive. This is a preview recipe.
lb config \
  --mode ubuntu \
  --distribution "$UBUNTU_SUITE" \
  --architectures "$ARCH" \
  --binary-images iso-hybrid \
  --archive-areas "main restricted universe multiverse" \
  --debian-installer false \
  --bootappend-live "boot=live components username=stoney hostname=stoney-live quiet splash" \
  --apt-recommends true \
  --apt-indices false \
  --memtest none

lb build

ISO="$(find "$WORK_DIR" -maxdepth 1 -type f -name '*.iso' -print -quit)"
if [[ -z "$ISO" ]]; then
  echo "Build completed but no ISO was found. Inspect $LOG." >&2
  exit 4
fi
DEST="$OUT_DIR/stoney-linux-${UBUNTU_SUITE}-${ARCH}.iso"
cp "$ISO" "$DEST"
sha256sum "$DEST" > "$DEST.sha256"
{
  echo "name=Stoney Linux"
  echo "suite=$UBUNTU_SUITE"
  echo "architecture=$ARCH"
  echo "built_utc=$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
  echo "kernel=$(uname -r)"
  echo "live_build_version=$(lb --version 2>&1 | head -n1)"
  echo "sha256=$(sha256sum "$DEST" | awk '{print $1}')"
} > "$OUT_DIR/build-info.txt"
echo "ISO: $DEST"
echo "Checksum: $DEST.sha256"
echo "Build metadata: $OUT_DIR/build-info.txt"
echo "Build log: $LOG"
