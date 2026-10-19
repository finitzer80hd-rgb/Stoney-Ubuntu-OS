# Stoney Linux

Lightweight Ubuntu-based XFCE desktop remix for modern 64-bit PCs and laptops.

## Status

This repository contains the initial build recipe and test workflow. **No ISO is checked in, and no ISO has been built or boot-tested by this repository automation yet.** Treat output as a preview until it has passed the VM and hardware test plan.

## Build approach

Ubuntu's own image infrastructure is based on `livecd-rootfs`. Its configuration differs by Ubuntu release, so this project includes a conservative `live-build` starter recipe to validate the package selection and hooks. Ubuntu/live-build compatibility can vary; if `lb build` fails, preserve `out/build.log` and see the troubleshooting section rather than assuming an ISO was created.

Default target: Ubuntu 24.04 LTS (`noble`), amd64. XFCE, LightDM, NetworkManager, core utilities and common desktop apps.

## Build on Ubuntu

Use a clean Ubuntu 24.04 LTS amd64 VM with internet access, sudo, 8 GB RAM recommended, and at least 30 GB free disk space.

```bash
git clone https://github.com/finitzer80hd-rgb/Stoney-Ubuntu-OS.git
cd Stoney-Ubuntu-OS
sudo bash scripts/build-iso.sh
```

Optional environment variables:

```bash
sudo env UBUNTU_SUITE=noble ARCH=amd64 bash scripts/build-iso.sh
```

The script installs build dependencies, writes a build log, and if successful saves the ISO and SHA-256 checksum under `out/`.

## Test output

```bash
bash scripts/test-iso.sh out/stoney-linux-noble-amd64.iso
sha256sum -c out/stoney-linux-noble-amd64.iso.sha256
sudo apt install qemu-system-x86
qemu-system-x86_64 -m 4096 -smp 4 -cdrom out/stoney-linux-noble-amd64.iso -boot d -nic user
```

Check that it boots to XFCE, networking works, and shutdown/reboot work. Test UEFI and real hardware separately.

## Known limitations

- The initial recipe does not include a tested graphical disk installer.
- Compatibility of the Debian `live-build` tool with Ubuntu archives is not guaranteed for every tool version/release.
- Package versions are resolved from live repositories; builds are not yet bit-for-bit reproducible. Pin repository snapshots and package versions before production releases.
- Drivers/firmware vary by machine. Test Wi-Fi, graphics, Bluetooth, audio, suspend/resume and external displays.

## Layout

- `scripts/build-iso.sh` — ISO build entry point.
- `scripts/test-iso.sh` — file/boot-catalog checks and QEMU instructions.
- `config/package-lists/stoney.list.chroot` — packages included in the live system.
- `config/hooks/live/` — live image customization hook.
- `docs/TEST-PLAN.md` — validation checklist.
- `branding/` — location for original Stoney Linux branding assets.

## License

Build scripts and project documentation are MIT-licensed. Included packages retain their own licenses.
