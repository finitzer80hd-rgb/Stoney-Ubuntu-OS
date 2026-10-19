# Stoney Linux preview test plan

## Image checks
- Run `scripts/test-iso.sh` on the generated ISO.
- Verify the SHA-256 checksum.
- Inspect the El Torito boot catalog using xorriso.

## Virtual machine checks
- Boot in QEMU with 4 GB RAM and 4 vCPUs.
- Confirm live boot reaches XFCE.
- Confirm terminal, file manager, settings manager and display manager work.
- Confirm NetworkManager connects through user-mode networking.
- Test audio if a virtual audio device is enabled.
- Test shutdown and reboot.

## Hardware checks before release
- Test UEFI boot with Secure Boot enabled and disabled.
- Test Intel and AMD graphics, Wi-Fi, Bluetooth, audio, suspend/resume and external displays.
- Test on at least one laptop and one desktop.
- Verify APT updates, firmware licensing and package notices.
- Never install a preview image on a disk containing important data.

## Release blockers
- A tested graphical installer is not included in this starter.
- Validate the live-build toolchain against the chosen Ubuntu suite.
- Add package/version pinning, release signing and published checksums before distribution.
