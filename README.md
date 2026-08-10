# Mann Industries Linux (MI Linux)

<p align="center">
  <img src=".github/assets/mannindustries-logo.png" alt="MI Linux logo" width="420">
</p>

Mann Industries Linux, short name **MI Linux**, is a Debian Testing/Forky-based desktop operating system project from Mann Industries. The first public release is **MI Linux Forky Founder — Founder Preview**.

MI Linux is being created for people who want a polished, beginner-friendly Linux desktop without giving up modern hardware support, gaming readiness, privacy, or control over system updates. It is not just a theme pack. The goal is a real installable operating system with a live ISO, Calamares installer, MI Linux update path, documentation, checksums, signatures, and a public build recipe.

> Website status: the MI Linux website at `https://mannindustries.org/mi-linux` is not live yet. It is planned and will be available soon with downloads, screenshots, release notes, install guides, verification instructions, known issues, and support links.

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
- **Secure Boot supported:** Secure Boot support is a first-release goal, not an afterthought.
- **No Snap installed by default:** the system uses Debian packages plus Flatpak/Flathub and GNOME Software for app discovery.
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

The website is not up yet. It will be published soon and will include:

- download links;
- screenshots and a visual tour;
- beginner-friendly install guide;
- USB creation instructions;
- SHA256, SHA512, and GPG verification steps;
- release notes;
- known issues;
- recommended apps;
- support and bug-report links;
- links back to this public GitHub build source.

Until the website is live, this GitHub repository is the public source for the MI Linux build recipe, documentation, and early Founder Preview development.

## Plans going forward

The roadmap for MI Linux includes:

1. **Founder Preview ISO testing** — boot the live ISO, verify the desktop, test installation, confirm update behavior, and document known issues.
2. **Public website launch** — publish `mannindustries.org/mi-linux` with screenshots, install instructions, release notes, checksums, signatures, and support links.
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
- `website/` — static website content for `mannindustries.org/mi-linux`

## Licensing

- Build scripts: GPLv3
- Documentation: CC BY-SA 4.0
- MI Linux/Mann Industries names, logos, wallpapers, boot art, and visual branding: All Rights Reserved / Mann Industries-owned
- Unofficial remixes are allowed only if MI Linux/Mann Industries branding is removed and the remix is not presented as an official MI Linux build.
