# Mann Industries Linux (MI Linux)

<p align="center">
  <img src=".github/assets/mannindustries-logo.png" alt="MI Linux logo" width="420">
</p>

Mann Industries Linux, short name **MI Linux**, is a Debian Testing/Forky-based desktop operating system project. The first public release is **MI Linux Forky Founder — Founder Preview**.

This is intended to be a real installable Linux OS, not just a theme pack:

- Debian live-build based ISO
- Live desktop with Calamares installer
- MI Linux apt repository at `https://apt.mannindustries.org`
- Release-specific apt suites: `forky-founder` and `forky-tester`
- Dedicated archive signing key/keyring package
- Custom MI Linux Update Manager
- MI Linux branding packages
- Website/download documentation
- Checksums and GPG signatures for ISO releases

## Release goals

- Polished GNOME desktop with MI Linux bottom taskbar
- Debian Testing/Forky base with a curated 3-month delayed update model
- Wayland default, X11 available
- Latest stable Secure Boot-supported kernel that supports Waydroid, Android binder IPC, and binderfs
- UEFI + Legacy BIOS support
- Secure Boot supported in the first release
- Flatpak/Flathub enabled, no Snap installed by default
- Gaming-ready base support without preinstalling Steam
- Privacy-first: no telemetry, analytics, or automatic crash reporting

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
