#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
mkdir -p "$ROOT/config/packages.chroot"

ONLYOFFICE_DEB="$ROOT/config/packages.chroot/onlyoffice-desktopeditors_amd64.deb"
ONLYOFFICE_URL="https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb"
if [ ! -s "$ONLYOFFICE_DEB" ]; then
  echo "Downloading ONLYOFFICE Desktop Editors for inclusion in the ISO..."
  tmp="$ONLYOFFICE_DEB.tmp"
  curl -fL -C - --retry 3 --connect-timeout 30 -o "$tmp" "$ONLYOFFICE_URL"
  work=$(mktemp -d)
  dpkg-deb -R "$tmp" "$work"
  # Avoid optional font/EULA packages being pulled into unattended ISO builds.
  sed -i '/^Recommends:/d' "$work/DEBIAN/control"
  dpkg-deb -b "$work" "$tmp.repacked"
  rm -rf "$work"
  dpkg-deb -I "$tmp.repacked" >/dev/null
  ar t "$tmp.repacked" >/dev/null
  mv "$tmp.repacked" "$ONLYOFFICE_DEB"
  rm -f "$tmp"
fi
for pkg in "$ROOT"/packages/*; do
  [ -d "$pkg/debian" ] || continue
  (cd "$pkg" && dpkg-buildpackage -us -uc -b)
done
find "$ROOT/packages" -maxdepth 1 -name '*.deb' -exec cp -f {} "$ROOT/config/packages.chroot/" \;
ls -lh "$ROOT/config/packages.chroot"/*.deb
