#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ISO="${1:-$ROOT/out/stoney-linux-noble-amd64.iso}"
if [[ ! -f "$ISO" ]]; then
  echo "ISO not found: $ISO" >&2
  echo "Build first with sudo ./scripts/build-iso.sh" >&2
  exit 1
fi
echo "== File integrity =="
file "$ISO"
sha256sum "$ISO"
if command -v xorriso >/dev/null 2>&1; then
  echo "== ISO volume / boot catalog inspection =="
  xorriso -indev "$ISO" -pvd_info
  xorriso -indev "$ISO" -report_el_torito plain
else
  echo "xorriso not installed; skipping boot catalog inspection."
fi
if command -v qemu-system-x86_64 >/dev/null 2>&1; then
  echo "Boot interactively with:"
  echo "qemu-system-x86_64 -m 4096 -smp 4 -cdrom '$ISO' -boot d -nic user"
else
  echo "QEMU not installed. Install qemu-system-x86 to test the ISO in a VM."
fi
