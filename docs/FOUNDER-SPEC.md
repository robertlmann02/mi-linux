# MI Linux Forky Founder — Founder Preview Spec

## Identity

- Official name: Mann Industries Linux
- Short name: MI Linux
- First release/version: MI Linux Forky Founder
- Public label: Founder Preview
- Website: https://mannindustries.org/mi-linux
- GitHub target: https://github.com/robertlmann02/mi-linux

## Base and update model

- Base: Debian Testing / Forky
- Update model: curated/delayed, about 6 months behind direct Debian Testing/Forky
- Release cadence: quarterly
- Apt repo: https://apt.mannindustries.org
- Apt suites:
  - `forky-founder` enabled by default
  - `forky-tester` included but disabled/commented out
- Dedicated MI Linux archive signing key from the start
- Security updates automatic
- Non-security updates notify and wait for user approval
- Prompt for Timeshift snapshot before non-security updates
- Custom MI Linux Update Manager included in Founder Preview

## Desktop

- GNOME desktop
- Wayland default, X11 available
- Bottom taskbar is the main launcher
- Menu button: `MI Linux` with MI logo
- Preinstall and enable GNOME extensions:
  - Dash to Panel
  - ArcMenu
  - AppIndicator/KStatusNotifier
  - Blur my Shell
  - User Themes
- Default pinned apps:
  - Firefox
  - Files
  - GNOME Terminal
  - ONLYOFFICE
  - Geary
  - GNOME Software
  - Settings
  - Welcome app

## Branding

- Custom GRUB theme
- Custom Plymouth splash
- Custom GDM login background/theme
- MI Linux wallpapers, only 4K wallpaper versions
- Calamares installer branding

## Default apps and support

Installed by default:
- Firefox
- ONLYOFFICE
- Geary
- Rhythmbox
- VLC
- Loupe/Image Viewer only, not GNOME Photos
- GNOME Terminal
- GNOME Software with Flatpak support
- Flatpak and Flathub
- Timeshift
- common archive/compression tools
- common printer/scanner support, but no dedicated scanner app
- no dedicated PDF viewer because ONLYOFFICE can open PDFs

Not installed by default:
- Google Chrome
- Microsoft Edge
- Steam
- Bottles/Wine/Winetricks/PlayOnLinux
- Waydroid
- GIMP and other creative tools
- local AI/Hermes/Ollama/private assistant tools
- Snap

## Recommended Apps categories

Browsers:
- Google Chrome
- Microsoft Edge

Gaming:
- Steam
- Lutris
- Heroic Games Launcher
- ProtonUp-Qt
- OBS Studio
- Discord

Windows Apps:
- Bottles
- Wine
- Winetricks
- PlayOnLinux

Creative Tools:
- GIMP
- Inkscape
- Krita
- Blender
- Kdenlive
- Audacity

Developer Tools:
- VS Code
- VSCodium
- Git
- GitHub Desktop
- Docker
- Podman
- Python tooling
- Node.js tooling

Android Apps / Waydroid:
- Waydroid
- Installer offers vanilla Waydroid and Waydroid with GAPPS/Google Play choices
- No user-facing readiness screen; MI Linux itself must already ship a Waydroid-ready kernel

Drivers/Hardware:
- NVIDIA driver installer option

## Kernel/hardware

- x86_64 first; ARM later
- Modern 64-bit CPU from last 10 years recommended
- RAM: 8 GB minimum, 16 GB recommended
- Storage: 128 GB minimum, 500 GB recommended
- Firmware: include Debian non-free firmware by default
- NVIDIA: detection/installer tool, not preinstalled globally
- Kernel: latest stable kernel suitable for the release with Waydroid/binder/binderfs support and Secure Boot support
- Boot: UEFI + Legacy BIOS support
- Bootloader: GRUB

## Security

- UFW enabled by default
- default deny incoming, default allow outgoing
- OpenSSH allowed before enabling UFW
- MI Linux command-line/background protection tools by default:
  - ClamAV
  - clamav-daemon/freshclam
  - rkhunter
  - chkrootkit
  - unattended-upgrades
  - apt-listchanges
  - low-impact scheduled ClamAV and rootkit scans
- No ClamTK GUI
- MI Linux security timer names:
  - mi-linux-clamav-quick-scan.timer
  - mi-linux-clamav-full-scan.timer
  - mi-linux-rootkit-scan.timer
- Welcome app shows simple security status

## Website/distribution

- Download from mannindustries.org/mi-linux and GitHub Releases
- Publish SHA256, SHA512, and GPG signature for ISO downloads
- No torrent downloads for first release; add later if downloads grow
- Website includes screenshots and visual tour
- Beginner-friendly install guide with screenshots
- USB tools listed: Balena Etcher, Rufus, GNOME Disks, Ventoy
- Known Issues section
- Bug report link to GitHub Issues
- Code of Conduct and contributing guide
- Keep GitHub Issues simple; no issue templates initially
- Hardware compatibility page added later after user reports
