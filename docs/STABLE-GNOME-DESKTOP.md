# Stable GNOME desktop policy

MI Linux uses a Zorin-style GNOME approach instead of depending on ad-hoc user tweaks. The desktop is treated as part of the OS.

## Goal

Keep the familiar MI Linux desktop stable across package updates, new user profiles, and accidental GNOME settings drift:

- bottom taskbar
- application menu on the left
- app indicators
- dark blue Mann Industries theme
- Blur my Shell panel styling
- pinned everyday apps
- MI Linux menu identity and wallpaper

## How MI Linux keeps the desktop stable

1. Ship the desktop components as packages.

   The ISO package list installs GNOME Shell extensions from Debian packages where possible:

   - `gnome-shell-extension-dash-to-panel`
   - `gnome-shell-extension-appindicator`
   - `gnome-shell-extension-blur-my-shell`
   - `gnome-shell-extension-arc-menu`
   - `gnome-shell-extension-user-theme`
   - `gnome-shell-extension-desktop-icons-ng`

   This is more reliable than asking users to install random extensions manually from a browser.

2. Store the layout as system defaults.

   `mi-linux-default-settings` installs dconf defaults under:

   - `/etc/dconf/db/local.d/00-mi-linux-defaults`
   - `/etc/dconf/db/local.d/90-mannpro-gnome-hardening`

   These files define the desktop layout for new users and for machines that need the MannPro-style GNOME profile reapplied.

3. Lock the critical layout keys.

   Critical keys are locked under:

   - `/etc/dconf/db/local.d/locks/90-mannpro-gnome-hardening`

   Locked keys keep updates or accidental changes from silently turning off the taskbar/menu layout.

4. Keep GNOME version changes controlled.

   MI Linux should not chase untested GNOME Shell jumps for normal users. Quarterly images and package updates should verify that the packaged extensions still work with the selected GNOME Shell version before promoting the update path.

## Operational checklist for an installed machine

Run these checks after applying or updating the stable desktop profile:

```bash
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export DBUS_SESSION_BUS_ADDRESS=unix:path=$XDG_RUNTIME_DIR/bus

gsettings get org.gnome.shell enabled-extensions
gsettings writable org.gnome.shell enabled-extensions
gsettings get org.gnome.desktop.interface gtk-theme
gsettings writable org.gnome.desktop.interface gtk-theme
gsettings get org.gnome.shell.extensions.dash-to-panel panel-position
gsettings writable org.gnome.shell.extensions.dash-to-panel panel-position

gsettings --schemadir /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/schemas get org.gnome.shell.extensions.arcmenu menu-button-icon
gsettings --schemadir /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/schemas writable org.gnome.shell.extensions.arcmenu menu-button-icon

sudo apt-get check
systemctl --failed --no-legend --no-pager
```

Expected results:

- required extensions are enabled;
- critical layout keys report `false` for writable;
- the GTK/icon theme is `ZorinBlue-Dark` or the current MI Linux theme;
- Dash to Panel is set to `BOTTOM`;
- ArcMenu uses the MI/Mann Industries menu emblem;
- `apt-get check` succeeds.

## Notes for installed-machine parity

Existing private workstations can use host-specific extension IDs such as `appindicatorsupport@rgcjonas.gmail.com` and may include extra extensions like Tiling Shell. Public MI Linux images should use the package-based MI Linux defaults. Do not hard-code private hostnames, IP addresses, or local build paths in the public repository.
