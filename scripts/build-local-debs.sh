#!/bin/sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
mkdir -p "$ROOT/config/packages.chroot"
for pkg in "$ROOT"/packages/*; do
  [ -d "$pkg/debian" ] || continue
  (cd "$pkg" && dpkg-buildpackage -us -uc -b)
done
find "$ROOT/packages" -maxdepth 1 -name '*.deb' -exec cp -f {} "$ROOT/config/packages.chroot/" \;
ls -lh "$ROOT/config/packages.chroot"/*.deb
