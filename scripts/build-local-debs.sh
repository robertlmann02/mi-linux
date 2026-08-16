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
  dpkg-deb -I "$tmp" >/dev/null
  mv "$tmp" "$ONLYOFFICE_DEB"
fi
for pkg in "$ROOT"/packages/*; do
  [ -d "$pkg/debian" ] || continue
  (cd "$pkg" && dpkg-buildpackage -us -uc -b)
done
find "$ROOT/packages" -maxdepth 1 -name '*.deb' -exec cp -f {} "$ROOT/config/packages.chroot/" \;
ls -lh "$ROOT/config/packages.chroot"/*.deb
