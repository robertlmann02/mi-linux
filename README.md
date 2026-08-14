# Mann Industries Linux (MI Linux)

<p align="center">
  <img src=".github/assets/mannindustries-logo.png" alt="MI Linux logo" width="420">
</p>

Mann Industries Linux, short name **MI Linux**, is a Debian Testing/Forky-based desktop operating system project from Mann Industries. The first public release is **MI Linux Forky Founder — Founder Preview**.

MI Linux is being created for people who want a polished, beginner-friendly Linux desktop without giving up modern hardware support, gaming readiness, privacy, or control over system updates. It is not just a theme pack. The goal is a real installable operating system with a live ISO, Calamares installer, MI Linux update path, documentation, checksums, signatures, and a public build recipe.

> Website status: the MI Linux website is live at `https://mannindustries.org/mi-linux/`. A direct subdomain is also available at `https://mi-linux.mannindustries.org/`. The site is self-hosted on MannCloud and includes downloads, checksums, install guidance, known issues, and source links.

## Who is this for?

MI Linux is for new and everyday Linux users who want a desktop that feels familiar immediately, but is still built on a real Debian base. It is meant for people moving from Windows or macOS, gamers who need good hardware and graphics support, and users who want a clean desktop that does not require online accounts, telemetry, or confusing app-store decisions before they can start working.

It is also for users who like Debian but want a more complete desktop experience from the first boot: GNOME already shaped into a practical taskbar/menu layout, common apps selected, firmware included, updates managed clearly, and rollback/security tools visible without making the system feel heavy or corporate.

## Why this OS was created

MI Linux was created because many Linux choices force users to pick between extremes:

- very stable but older packages;
- very current but too risky for normal users;
- polished desktops that hide too much control;
- powerful systems that expect new users to know too much up front;
- app ecosystems that push users toward unwanted defaults.

MI Linux is designed to sit in the middle: more current than Debian Stable, calmer than raw Debian Testing, polished enough for beginners, and transparent enough for advanced users. The Founder Preview is the first step toward a Mann Industries desktop OS that can be downloaded, verified, booted, installed, updated, and improved in the open.

## How MI Linux stands out

- **Curated Debian Testing/Forky base:** MI Linux tracks Debian Testing/Forky through a controlled, roughly 3-month delayed update model instead of sending normal users directly into raw Testing updates.
- **MI Linux update channel:** systems use MI Linux apt suites such as `forky-founder` and `forky-tester`, with a dedicated archive signing key and a custom Update Manager planned around the delayed-update policy.
- **Polished GNOME desktop:** GNOME is configured around a familiar bottom taskbar, MI Linux menu identity, AppIndicator support, Blur my Shell, User Themes, ArcMenu, and Dash to Panel.
- **Beginner-friendly installer:** the live ISO boots into a desktop and uses Calamares for graphical installation.
- **Gaming-ready foundation:** i386 multiarch, Vulkan support, GameMode, MangoHud, controller support, and Proton-management support are part of the plan while Steam stays optional.
- **Waydroid-ready direction:** MI Linux targets a latest stable Secure Boot-supported kernel with Waydroid, Android binder IPC, and binderfs support.
- **Secure Boot supported:** MI Linux is built to support Secure Boot on compatible UEFI systems.
- **Debian packages plus Flatpak:** app discovery uses Debian packages, Flatpak/Flathub, and GNOME Software by default.
- **Privacy-first defaults:** no telemetry, no analytics, no automatic usage reporting, no required online account, and user-initiated bug reporting.
- **Mann Industries security baseline:** UFW firewall defaults, unattended security updates, Timeshift, ClamAV, rkhunter, chkrootkit, and low-impact scheduled background scans are included in the design.
- **Real release artifacts:** ISO downloads will include SHA256, SHA512, and GPG signature verification.

## Current release goals

- Debian live-build based ISO
- Live desktop with Calamares installer
- Debian Testing/Forky base with a curated 3-month delayed update model
- MI Linux apt repository at `https://apt.mannindustries.org`
- Release-specific apt suites: `forky-founder` and `forky-tester`
- Dedicated archive signing key/keyring package
- Custom MI Linux Update Manager
- MI Linux Welcome app
- Flatpak/Flathub enabled
- GNOME Software included for apps
- Firefox default browser
- ONLYOFFICE default office suite
- Geary mail, Rhythmbox music, VLC media playback
- Timeshift/System Restore support
- UFW, ClamAV, rkhunter, chkrootkit, and unattended security updates
- Secure Boot, UEFI, and Legacy BIOS support
- Checksums and GPG signatures for ISO releases

## Website and downloads

The official website is planned for:

```text
https://mannindustries.org/mi-linux
```

The website is live and includes download links, checksums, install guidance, known issues, release notes, support/bug-report links, and links back to this public GitHub build source. The first Founder Preview release is published on GitHub, with the full ISO hosted on MannCloud:

- GitHub Release: `https://github.com/robertlmann02/mi-linux/releases/tag/v0.1.0-founder-preview`
- Website: `https://mannindustries.org/mi-linux/`
- Direct website subdomain: `https://mi-linux.mannindustries.org/`
- ISO download: `https://manncloud.mannindustries.org/downloads/mi-linux/founder-preview/mi-linux-forky-founder-amd64.iso`
- SHA256: `https://manncloud.mannindustries.org/downloads/mi-linux/founder-preview/mi-linux-forky-founder-amd64.iso.sha256`
- SHA512: `https://manncloud.mannindustries.org/downloads/mi-linux/founder-preview/mi-linux-forky-founder-amd64.iso.sha512`

## Create a bootable USB from GitHub

Users can create a bootable USB from the GitHub release page:

1. Open the Founder Preview release: `https://github.com/robertlmann02/mi-linux/releases/tag/v0.1.0-founder-preview`.
2. Download the MI Linux ISO using the MannCloud ISO link in the release notes.
3. Download the matching `.sha256` and `.sha512` files from the release assets or MannCloud links.
4. Download the GPG signature when it is provided.
5. Verify the ISO checksums/signature.
6. Write the ISO to a USB drive:
   - PC/Windows users: use Rufus or balenaEtcher.
   - Mac users: use balenaEtcher, or the macOS Terminal `diskutil`/`dd` method in the full guide.
   - Linux users: use GNOME Disks, Ventoy, or the included `scripts/write-usb.sh` helper.
7. Boot the computer from the USB and choose **Install MI Linux** from the live desktop.

Full step-by-step instructions for PC, Mac, and Linux users are in:

```text
docs/CREATE-BOOTABLE-USB.md
```

Linux users can also clone this repository and use the included checked writer:

```bash
git clone https://github.com/robertlmann02/mi-linux.git
cd mi-linux
lsblk -o NAME,PATH,SIZE,MODEL,VENDOR,TRAN,RM,RO,TYPE,MOUNTPOINTS,FSTYPE,LABEL
OVERWRITE=YES sudo -E ./scripts/write-usb.sh /path/to/mi-linux-forky-founder-amd64.iso /dev/sdX
```

Use the whole USB disk, such as `/dev/sdb`, not a partition such as `/dev/sdb1`. The helper refuses non-removable targets and verifies that the USB matches the ISO after writing.

## Plans going forward

The roadmap for MI Linux includes:

1. **Founder Preview ISO testing** — boot the live ISO, verify the desktop, test installation, confirm update behavior, and document known issues.
2. **Public website launch** — live at `https://mannindustries.org/mi-linux/` with install guidance, release links, checksums, known issues, and source links.
3. **MI Linux apt repository** — bring `apt.mannindustries.org` online with signed `forky-founder` and `forky-tester` suites.
4. **Custom Update Manager** — ship a GTK/GNOME MI Linux Update Manager that shows channel status, applies the 3-month delay policy, handles non-security update prompts, and recommends Timeshift snapshots before larger updates.
5. **Welcome app and Recommended Apps** — provide a clear first-run experience with optional browsers, gaming apps, Windows-app tools, creative tools, developer tools, NVIDIA driver setup, and Waydroid choices.
6. **Secure Boot and Waydroid validation** — verify the selected kernel, Secure Boot path, binder/binderfs support, and Waydroid install experience on real hardware.
7. **Quarterly releases** — publish updated ISOs on a 3-month cadence after testing and documenting changes.
8. **Community feedback** — use GitHub Issues for first-release bug reports and improve hardware notes after real users report results.

## Repository layout

- `auto/` — live-build helper scripts
- `config/` — live-build configuration, package lists, hooks, includes
- `packages/` — MI Linux `.deb` package source skeletons
- `src/mi-linux-update-manager/` — GTK/GNOME Update Manager
- `src/mi-linux-welcome/` — GTK/GNOME Welcome app
- `apt-repo/` — apt repository policy and publishing notes
- `docs/` — user and release documentation
- `docs/CREATE-BOOTABLE-USB.md` — GitHub download and bootable USB instructions
- `website/` — static website content for `mannindustries.org/mi-linux`

## Licensing

- Build scripts: GPLv3
- Documentation: CC BY-SA 4.0
- MI Linux/Mann Industries names, logos, wallpapers, boot art, and visual branding: All Rights Reserved / Mann Industries-owned
- Unofficial remixes are allowed only if MI Linux/Mann Industries branding is removed and the remix is not presented as an official MI Linux build.
