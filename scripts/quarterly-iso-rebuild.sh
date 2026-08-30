#!/usr/bin/env bash
# Build a fresh MI Linux ISO every quarterly release cycle.
# Intended runner: MannsPi5Ai user/systemd timer.
# Intended builder: MannPro x86_64 over SSH.
set -euo pipefail

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

PI_REPO="${MI_LINUX_PI_REPO:-/home/robertlmann02/mi-linux}"
BUILDER_HOST="${MI_LINUX_BUILDER_HOST:-10.0.0.7}"
BUILDER_USER="${MI_LINUX_BUILDER_USER:-robertlmann02}"
BUILDER_REPO="${MI_LINUX_BUILDER_REPO:-/mnt/steam-ssd/mi-linux-build/mi-linux}"
REMOTE_URL="${MI_LINUX_REMOTE_URL:-git@github.com:robertlmann02/mi-linux.git}"
BRANCH="${MI_LINUX_BRANCH:-main}"
LOCAL_CANDIDATE_ROOT="${MI_LINUX_LOCAL_CANDIDATE_ROOT:-/home/robertlmann02/mi-linux-quarterly-candidates}"
LOG_ROOT="${MI_LINUX_LOG_ROOT:-/home/robertlmann02/mi-linux-quarterly-rebuild-logs}"
PUBLISH_CANDIDATE_TO_MANNCLOUD="${MI_LINUX_PUBLISH_CANDIDATE_TO_MANNCLOUD:-1}"
MANNCLOUD_CANDIDATE_ROOT="${MI_LINUX_MANNCLOUD_CANDIDATE_ROOT:-/opt/manncloud/downloads/mi-linux/quarterly-candidates}"

mkdir -p "$LOG_ROOT" "$LOCAL_CANDIDATE_ROOT"
RUN_STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
LOG_FILE="$LOG_ROOT/quarterly-iso-rebuild-$RUN_STAMP.log"
exec > >(tee -a "$LOG_FILE") 2>&1

log() { printf '[%s] %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*"; }
fail() { log "ERROR: $*"; exit 1; }

quarter_release_date() {
  python3 - <<'PY'
import datetime as dt
now = dt.date.today()
q_months = [3, 6, 9, 12]
# Timer runs in quarter months. If manually run in another month, pick next quarter.
for m in q_months:
    if (now.month, now.day) <= (m, 1):
        print(dt.date(now.year, m, 1).isoformat())
        break
else:
    print(dt.date(now.year + 1, 3, 1).isoformat())
PY
}

RELEASE_DATE="${MI_LINUX_RELEASE_DATE:-$(quarter_release_date)}"
RELEASE_COMPACT="${RELEASE_DATE//-/}"
REMOTE="${BUILDER_USER}@${BUILDER_HOST}"
REMOTE_OUT="${BUILDER_REPO}/out/quarterly-iso/${RELEASE_DATE}"
ISO_NAME="mi-linux-forky-founder-amd64-${RELEASE_COMPACT}.iso"
LOCAL_OUT="$LOCAL_CANDIDATE_ROOT/$RELEASE_DATE"
mkdir -p "$LOCAL_OUT"

log "MI Linux quarterly ISO rebuild starting"
log "release_date=$RELEASE_DATE"
log "builder=$REMOTE"
log "builder_repo=$BUILDER_REPO"
log "local_candidate_out=$LOCAL_OUT"

cd "$PI_REPO"
git fetch origin "$BRANCH"
LOCAL_HEAD="$(git rev-parse HEAD)"
ORIGIN_HEAD="$(git rev-parse origin/$BRANCH)"
log "pi_repo_head=$LOCAL_HEAD origin_$BRANCH=$ORIGIN_HEAD"

if ! ssh -o BatchMode=yes -o ConnectTimeout=20 "$REMOTE" 'hostname; uname -m' >/tmp/mi-linux-builder-check.$$ 2>&1; then
  cat /tmp/mi-linux-builder-check.$$ || true
  rm -f /tmp/mi-linux-builder-check.$$
  fail "builder is unreachable; leaving existing public ISO untouched"
fi
cat /tmp/mi-linux-builder-check.$$
rm -f /tmp/mi-linux-builder-check.$$

ssh "$REMOTE" "set -euo pipefail
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
arch=\$(uname -m)
[ \"\$arch\" = x86_64 ] || { echo \"Builder must be x86_64, got \$arch\" >&2; exit 2; }
mkdir -p \"$(dirname "$BUILDER_REPO")\"
if [ ! -d \"$BUILDER_REPO/.git\" ]; then
  git clone \"$REMOTE_URL\" \"$BUILDER_REPO\"
fi
cd \"$BUILDER_REPO\"
git fetch origin \"$BRANCH\"
git checkout \"$BRANCH\"
git reset --hard \"origin/$BRANCH\"
git clean -fd -e cache -e config/packages.chroot/onlyoffice-desktopeditors_amd64.deb
printf 'builder_head='
git rev-parse HEAD
./scripts/validate-tree.sh
python3 ./scripts/mi-linux-quarterly-update.py --release-date \"$RELEASE_DATE\" --mode prepare
./auto/clean || true
./auto/config
./auto/build
mkdir -p \"$REMOTE_OUT\"
iso=''
for candidate in live-image-amd64.hybrid.iso mannpro-live-image-amd64.hybrid.iso mi-linux-forky-founder-amd64.iso; do
  if [ -s \"\$candidate\" ]; then iso=\"\$candidate\"; break; fi
done
[ -n \"\$iso\" ] || { echo 'No ISO output found after build' >&2; exit 3; }
cp -f \"\$iso\" \"$REMOTE_OUT/$ISO_NAME\"
cd \"$REMOTE_OUT\"
sha256sum \"$ISO_NAME\" > \"$ISO_NAME.sha256\"
sha512sum \"$ISO_NAME\" > \"$ISO_NAME.sha512\"
cp -f \"$BUILDER_REPO/out/quarterly-release/$RELEASE_DATE/quarterly-update-report.md\" . 2>/dev/null || true
cp -f \"$BUILDER_REPO/out/quarterly-release/$RELEASE_DATE/quarterly-update-report.json\" . 2>/dev/null || true
printf 'remote_iso='; realpath \"$ISO_NAME\"
cat \"$ISO_NAME.sha256\"
"

rsync -av --delete "$REMOTE:$REMOTE_OUT/" "$LOCAL_OUT/"
(cd "$LOCAL_OUT" && sha256sum -c "$ISO_NAME.sha256" && sha512sum -c "$ISO_NAME.sha512")
log "local_checksums_verified=yes"

if [ "$PUBLISH_CANDIDATE_TO_MANNCLOUD" = "1" ] && sudo -n true 2>/dev/null; then
  log "copying verified candidate artifacts into MannCloud download candidate directory"
  sudo mkdir -p "$MANNCLOUD_CANDIDATE_ROOT/$RELEASE_DATE"
  sudo rsync -a --delete "$LOCAL_OUT/" "$MANNCLOUD_CANDIDATE_ROOT/$RELEASE_DATE/"
  sudo find "$MANNCLOUD_CANDIDATE_ROOT/$RELEASE_DATE" -type f -exec chmod 0644 {} +
  sudo find "$MANNCLOUD_CANDIDATE_ROOT/$RELEASE_DATE" -type d -exec chmod 0755 {} +
  log "manncloud_candidate_out=$MANNCLOUD_CANDIDATE_ROOT/$RELEASE_DATE"
else
  log "MannCloud candidate copy skipped; either disabled or passwordless sudo unavailable"
fi

log "MI Linux quarterly ISO rebuild complete"
log "log_file=$LOG_FILE"
log "iso=$LOCAL_OUT/$ISO_NAME"
