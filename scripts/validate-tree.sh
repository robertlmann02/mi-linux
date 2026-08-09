#!/bin/sh
set -eu
sh -n auto/config auto/build auto/clean config/hooks/live/*.chroot config/includes.chroot/usr/local/sbin/mi-linux-security-scan
PYTHONDONTWRITEBYTECODE=1 python3 -m py_compile src/mi-linux-update-manager/mi-linux-update-manager.py src/mi-linux-welcome/mi-linux-welcome.py
find . -type d -name __pycache__ -prune -exec rm -rf {} +
if find . -path '*/__pycache__/*' -o -name '*.pyc' | grep .; then
  echo 'Python cache files found' >&2
  exit 1
fi
grep -RInE --exclude-dir=.git --exclude=validate-tree.sh 'gho_[A-Za-z0-9_]+|github_pat_|BEGIN (RSA|OPENSSH|PRIVATE) KEY|TOKEN=|SECRET=' . && exit 1 || true
echo 'MI Linux tree validation passed'
