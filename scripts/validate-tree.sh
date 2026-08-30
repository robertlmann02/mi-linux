#!/bin/sh
set -eu
sh -n auto/config auto/build auto/clean config/hooks/live/*.chroot config/hooks/normal/*.hook.binary config/includes.chroot/usr/local/sbin/mi-linux-security-scan config/includes.chroot/usr/bin/add-calamares-desktop-icon config/includes.chroot/usr/bin/calamares-install-debian
bash -n packages/mi-linux-default-settings/defaults/bin/mi-linux-wallpaper-sync-user packages/mi-linux-default-settings/defaults/sbin/mi-linux-wallpaper-sync-root packages/mi-linux-default-settings/defaults/sbin/mi-linux-gdm-wallpaper-theme
sh -n packages/mi-linux-default-settings/debian/postinst
PYTHONDONTWRITEBYTECODE=1 python3 -m py_compile src/mi-linux-update-manager/mi-linux-update-manager.py src/mi-linux-welcome/mi-linux-welcome.py
find . \( -path './chroot' -o -path './cache' \) -prune -o -type d -name __pycache__ -prune -exec rm -rf {} +
if find . \( -path './chroot' -o -path './cache' \) -prune -o \( -path '*/__pycache__/*' -o -name '*.pyc' \) -print | grep .; then
  echo 'Python cache files found' >&2
  exit 1
fi
find . \
  \( -path './.git' -o -path './chroot' -o -path './cache' -o -path './binary' -o -path './config/binary' -o -path './config/bootstrap' -o -path './config/chroot' -o -path './config/common' -o -path './config/source' \) -prune -o \
  -type f ! -name validate-tree.sh -print0 \
  | xargs -0 grep -InE 'gho_[A-Za-z0-9_]+|github_pat_|BEGIN (RSA|OPENSSH|PRIVATE) KEY|TOKEN=|SECRET=' \
  | grep -Ev "(your-r2-secret-access-key|scoped-cloudflare-api-token)'$" \
  && exit 1 || true
echo 'MI Linux tree validation passed'
