#!/bin/sh
set -eu
sh -n auto/config auto/build auto/clean config/hooks/live/*.chroot config/includes.chroot/usr/local/sbin/mi-linux-security-scan config/includes.chroot/usr/bin/add-calamares-desktop-icon config/includes.chroot/usr/bin/calamares-install-debian
PYTHONDONTWRITEBYTECODE=1 python3 -m py_compile src/mi-linux-update-manager/mi-linux-update-manager.py src/mi-linux-welcome/mi-linux-welcome.py
find . \( -path './chroot' -o -path './cache' \) -prune -o -type d -name __pycache__ -prune -exec rm -rf {} +
if find . \( -path './chroot' -o -path './cache' \) -prune -o \( -path '*/__pycache__/*' -o -name '*.pyc' \) -print | grep .; then
  echo 'Python cache files found' >&2
  exit 1
fi
grep -RInE --exclude-dir=.git --exclude=validate-tree.sh 'gho_[A-Za-z0-9_]+|github_pat_|BEGIN (RSA|OPENSSH|PRIVATE) KEY|TOKEN=|SECRET=' . && exit 1 || true
echo 'MI Linux tree validation passed'
