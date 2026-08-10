# Beginner Install Guide

This guide is for new Linux users installing MI Linux Forky Founder.

## Before you start

Minimum:
- 64-bit x86_64 PC
- 8 GB RAM
- 128 GB storage

Recommended:
- Modern 64-bit CPU from the last 10 years
- 16 GB RAM
- 500 GB storage

## Write the USB

Recommended USB tools:

- Rufus: good for PC/Windows users
- Balena Etcher: easiest for beginners and recommended for Mac users
- GNOME Disks: good for Linux users
- Ventoy: good for advanced users/testing multiple ISOs

For complete GitHub download, checksum verification, and bootable USB steps, see:

```text
docs/CREATE-BOOTABLE-USB.md
```

Quick GitHub flow:

1. Open the Founder Preview release:

   ```text
   https://github.com/robertlmann02/mi-linux/releases/tag/v0.1.0-founder-preview
   ```

2. Use the MannCloud ISO link in the release notes:

   ```text
   https://manncloud.mannindustries.org/s/Zn5m6Sm6syjb2A6/download
   ```

3. Download the `.sha256` and `.sha512` files from the release assets or MannCloud links, then verify the ISO.
4. Write it with the right tool for your computer: Rufus or balenaEtcher on PC/Windows, balenaEtcher on Mac, GNOME Disks or `scripts/write-usb.sh` on Linux, or Ventoy for advanced multi-ISO USB drives.

## Install

1. Download the ISO from the GitHub Release notes / MannCloud ISO link.
2. Verify SHA256 and SHA512; verify the GPG signature when it is provided.
3. Write the ISO to USB.
4. Boot from USB using UEFI or Legacy BIOS.
5. Try the live desktop.
6. Click Install MI Linux.
7. Use Calamares to choose disk, filesystem, and optional full-disk encryption.
8. Reboot into MI Linux.
9. Open Welcome app.
10. Create a Timeshift snapshot before major/non-security updates.
