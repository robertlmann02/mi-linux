# Installer Option C: Debian base with a cleaner MI Linux installer

Option C keeps MI Linux Debian-based and polishes the existing Calamares installer so the install flow feels closer to Fedora Workstation's simple, guided installer experience without rebasing MI Linux to Fedora or porting Anaconda.

## Decision

- Keep Debian/live-build as the MI Linux base and ISO build system.
- Keep Calamares as the installer.
- Brand the installer as the MI Linux installer instead of exposing unnecessary implementation details to beginner users.
- Make destructive disk actions clearer before installation begins.
- Use simple, guided text in the installer slideshow.

## Why not Anaconda directly

Fedora uses Anaconda. Anaconda is designed around Fedora/RHEL tooling such as RPM packages, DNF repositories, Kickstart, and Lorax/livemedia-creator. Using it directly on a Debian-based MI Linux ISO would require a large porting and maintenance effort.

For the current Debian-based MI Linux, the safer path is to improve Calamares and keep the installer stack aligned with Debian live-build.

## Current implementation changes

The first Option C pass makes these installer-facing changes:

- Enlarges the Calamares window from `800px,580px` to `960px,680px` for a calmer guided layout.
- Enables `prompt-install: true` so users get a clear point-of-no-return confirmation before disk changes begin.
- Enables `disable-cancel-during-exec: true` so users cannot interrupt the installer halfway through disk and bootloader work.
- Raises welcome-page requirement checks to `4 GB` RAM and `32 GB` storage, closer to a realistic minimum for a modern desktop install.
- Replaces the one-slide generic message with a three-slide MI Linux flow:
  - what the installer will ask for,
  - warning to choose the target disk carefully,
  - reminder to review the summary before committing.
- Updates the install guide to call it the MI Linux installer and mention the confirmation prompt.

## Follow-up work

Next polishing passes should be tested in a built ISO before release:

1. Boot the live ISO in a VM.
2. Launch `Install MI Linux`.
3. Confirm the window size and slideshow text render correctly.
4. Walk through install choices without writing until the summary page.
5. Confirm the point-of-no-return prompt appears when starting installation.
6. Run one full VM install to confirm partitioning, unpack, bootloader, reboot, login, Welcome app, and updates.
7. Update website screenshots and install docs after the VM installer flow is verified.

## Rollback

Revert these files if the installer UI or module behavior regresses:

- `config/includes.chroot/etc/calamares/settings.conf`
- `config/includes.chroot/etc/calamares/branding/mi-linux/branding.desc`
- `config/includes.chroot/etc/calamares/modules/welcome.conf`
- `config/includes.chroot/etc/calamares/branding/mi-linux/show.qml`
- `docs/INSTALL.md`
- `docs/INSTALLER-OPTION-C.md`
