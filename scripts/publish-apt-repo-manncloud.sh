#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C.UTF-8
export LANG=C.UTF-8

# Publish the MI Linux apt repository to MannCloud.
# Default source is this repo's local ./packages directory for forky-founder.
# forky-tester is intentionally separate: it only publishes packages from
# TESTER_SRC_DIR (default: ./packages-tester) or TESTER_SRC_HOST:TESTER_SRC_DIR.
# Set SRC_HOST/SRC_DIR only when intentionally publishing founder packages from
# a remote builder.

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
PROJECT_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
REPO=${REPO:-/opt/manncloud/apt-repo}
GPGHOME=${GPGHOME:-/opt/manncloud/mi-linux-archive-gpg}
SRC_HOST=${SRC_HOST:-}
SRC_DIR=${SRC_DIR:-$PROJECT_ROOT/packages}
TESTER_SRC_HOST=${TESTER_SRC_HOST:-}
TESTER_SRC_DIR=${TESTER_SRC_DIR:-$PROJECT_ROOT/packages-tester}
KEY_UID=${KEY_UID:-mi-linux-archive@mannindustries.org}

if ! sudo -n true 2>/dev/null; then
  echo "This publisher needs passwordless sudo on MannCloud/Pi5." >&2
  exit 1
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

copy_debs() {
  local host=$1
  local src=$2
  local dest=$3
  mkdir -p "$dest"
  if [ -n "$host" ]; then
    scp -q -o BatchMode=yes -o ConnectTimeout=10 "$host:$src"/'mi-linux-*.deb' "$dest"/ || true
  else
    if compgen -G "$src/mi-linux-*.deb" >/dev/null; then
      cp "$src"/mi-linux-*.deb "$dest"/
    fi
  fi
}

sudo mkdir -p \
  "$REPO/pool/forky-founder/main/m/mi-linux" \
  "$REPO/pool/forky-tester/main/m/mi-linux" \
  "$REPO/dists/forky-founder/main/binary-amd64" \
  "$REPO/dists/forky-tester/main/binary-amd64" \
  "$GPGHOME"
sudo chown -R root:root "$REPO" "$GPGHOME"
sudo chmod 755 "$REPO"
sudo chmod 700 "$GPGHOME"

copy_debs "$SRC_HOST" "$SRC_DIR" "$TMPDIR/forky-founder"
if ! compgen -G "$TMPDIR/forky-founder/mi-linux-*.deb" >/dev/null; then
  if [ -n "$SRC_HOST" ]; then
    echo "No MI Linux founder .deb packages copied from $SRC_HOST:$SRC_DIR" >&2
  else
    echo "No MI Linux founder .deb packages found in $SRC_DIR" >&2
  fi
  exit 1
fi

copy_debs "$TESTER_SRC_HOST" "$TESTER_SRC_DIR" "$TMPDIR/forky-tester"

# Keep suite indexes distinct. Founder packages do not automatically appear in tester.
sudo find "$REPO/pool/forky-founder/main/m/mi-linux" -type f -name 'mi-linux-*.deb' -delete
sudo find "$REPO/pool/forky-tester/main/m/mi-linux" -type f -name 'mi-linux-*.deb' -delete
sudo install -m 0644 "$TMPDIR/forky-founder"/mi-linux-*.deb "$REPO/pool/forky-founder/main/m/mi-linux/"
if compgen -G "$TMPDIR/forky-tester/mi-linux-*.deb" >/dev/null; then
  sudo install -m 0644 "$TMPDIR/forky-tester"/mi-linux-*.deb "$REPO/pool/forky-tester/main/m/mi-linux/"
fi

if ! sudo GNUPGHOME="$GPGHOME" gpg --list-secret-keys --with-colons "$KEY_UID" >/dev/null 2>&1; then
  cat >"$TMPDIR/keyparams" <<KEYEOF
Key-Type: RSA
Key-Length: 4096
Name-Real: MI Linux Archive Signing Key
Name-Email: $KEY_UID
Expire-Date: 0
%no-protection
%commit
KEYEOF
  sudo GNUPGHOME="$GPGHOME" gpg --batch --gen-key "$TMPDIR/keyparams" >/dev/null
fi

sudo GNUPGHOME="$GPGHOME" gpg --export "$KEY_UID" | sudo gpg --dearmor -o "$REPO/mi-linux-archive-keyring.gpg.tmp"
sudo mv "$REPO/mi-linux-archive-keyring.gpg.tmp" "$REPO/mi-linux-archive-keyring.gpg"
sudo GNUPGHOME="$GPGHOME" gpg --armor --export "$KEY_UID" | sudo tee "$REPO/mi-linux-archive-keyring.asc" >/dev/null

make_release_conf() {
  local suite=$1
  cat >"$TMPDIR/apt-release-$suite.conf" <<CONFEOF
APT::FTPArchive::Release::Origin "Mann Industries";
APT::FTPArchive::Release::Label "MI Linux";
APT::FTPArchive::Release::Suite "$suite";
APT::FTPArchive::Release::Codename "$suite";
APT::FTPArchive::Release::Architectures "amd64";
APT::FTPArchive::Release::Components "main";
APT::FTPArchive::Release::Description "Mann Industries Linux $suite repository";
CONFEOF
}

for suite in forky-founder forky-tester; do
  sudo mkdir -p "$REPO/dists/$suite/main/binary-amd64"
  make_release_conf "$suite"
  (cd "$REPO" && sudo dpkg-scanpackages --arch amd64 "pool/$suite" /dev/null) | sudo tee "$REPO/dists/$suite/main/binary-amd64/Packages" >/dev/null
  sudo gzip -9c "$REPO/dists/$suite/main/binary-amd64/Packages" | sudo tee "$REPO/dists/$suite/main/binary-amd64/Packages.gz" >/dev/null
  (cd "$REPO" && sudo apt-ftparchive -c "$TMPDIR/apt-release-$suite.conf" release "dists/$suite") | sudo tee "$REPO/dists/$suite/Release" >/dev/null
  sudo GNUPGHOME="$GPGHOME" gpg --batch --yes --pinentry-mode loopback --default-key "$KEY_UID" --clearsign -o "$REPO/dists/$suite/InRelease" "$REPO/dists/$suite/Release" >/dev/null
  sudo GNUPGHOME="$GPGHOME" gpg --batch --yes --pinentry-mode loopback --default-key "$KEY_UID" -abs -o "$REPO/dists/$suite/Release.gpg" "$REPO/dists/$suite/Release" >/dev/null
done

sudo tee "$REPO/README.txt" >/dev/null <<'READMEEOF'
MI Linux apt repository

Deb822 source:
Types: deb
URIs: https://apt.mannindustries.org
Suites: forky-founder
Components: main
Signed-By: /usr/share/keyrings/mi-linux-archive-keyring.gpg

Testing channel for early package validation only:
Suites: forky-tester

Public key:
https://apt.mannindustries.org/mi-linux-archive-keyring.asc
READMEEOF

printf 'Published MI Linux apt repo to %s\n' "$REPO"
printf 'forky-founder package count: '
sudo find "$REPO/pool/forky-founder" -type f -name '*.deb' | wc -l
printf 'forky-tester package count: '
sudo find "$REPO/pool/forky-tester" -type f -name '*.deb' | wc -l
