#!/usr/bin/env bash
set -euo pipefail

# Publish the current MI Linux ISO/checksums/signature to Cloudflare R2.
# This script intentionally does not store secrets. Provide R2 S3 credentials
# in the current shell, or source a local mode-600 env file before running it.
# CLOUDFLARE_API_TOKEN is optional and only used for bucket/dev-url automation.

BUCKET="${MI_LINUX_R2_BUCKET:-mi-linux-downloads}"
PREFIX="${MI_LINUX_R2_PREFIX:-founder-preview}"
ISO="${MI_LINUX_ISO:-/opt/manncloud/downloads/mi-linux/founder-preview/mi-linux-forky-founder-amd64.iso}"
SHA256_FILE="${MI_LINUX_SHA256:-${ISO}.sha256}"
SHA512_FILE="${MI_LINUX_SHA512:-${ISO}.sha512}"
SIG_FILE="${MI_LINUX_SIG:-${ISO}.sig}"
WEBSITE_DIR="${MI_LINUX_WEBSITE_DIR:-/home/robertlmann02/mi-linux/website}"
WRANGLER="${WRANGLER:-npx --yes wrangler@latest}"
RCLONE="${RCLONE:-rclone --config /dev/null}"
DRY_RUN=0
UPDATE_WEBSITE="${UPDATE_WEBSITE:-0}"
PUBLIC_BASE="${MI_LINUX_R2_PUBLIC_BASE:-}"

# For the 3 GB ISO, Wrangler cannot upload directly; it currently errors above
# 300 MiB. Use R2's S3-compatible API through rclone multipart upload.
R2_ACCOUNT_ID="${CLOUDFLARE_ACCOUNT_ID:-${R2_ACCOUNT_ID:-}}"
R2_ACCESS_KEY_ID="${R2_ACCESS_KEY_ID:-}"
R2_SECRET_ACCESS_KEY="${R2_SECRET_ACCESS_KEY:-}"

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

run() {
  printf '+ %s\n' "$*"
  if [[ "$DRY_RUN" != "1" ]]; then
    eval "$@"
  fi
}

need_file() {
  [[ -f "$1" ]] || { echo "Missing required file: $1" >&2; exit 1; }
}

need_file "$ISO"
need_file "$SHA256_FILE"
need_file "$SHA512_FILE"
need_file "$SIG_FILE"

ISO_NAME="$(basename "$ISO")"
SHA256_NAME="$(basename "$SHA256_FILE")"
SHA512_NAME="$(basename "$SHA512_FILE")"
SIG_NAME="$(basename "$SIG_FILE")"

printf 'MI Linux R2 publish plan\n'
printf '  bucket: %s\n' "$BUCKET"
printf '  prefix: %s\n' "$PREFIX"
printf '  iso: %s\n' "$ISO"
printf '  size: %s bytes\n' "$(stat -c%s "$ISO")"
printf '  sha256: %s\n' "$(sha256sum "$ISO" | awk '{print $1}')"
printf '  sha256 file: %s\n' "$(awk '{print $1}' "$SHA256_FILE")"

if [[ "$(sha256sum "$ISO" | awk '{print $1}')" != "$(awk '{print $1}' "$SHA256_FILE")" ]]; then
  echo "SHA256 file does not match ISO; refusing upload." >&2
  exit 1
fi

if [[ -z "$R2_ACCOUNT_ID" || -z "$R2_ACCESS_KEY_ID" || -z "$R2_SECRET_ACCESS_KEY" ]]; then
  cat >&2 <<'EOF'
Missing R2 S3 upload credentials.
Create an R2 API token in Cloudflare and provide these variables only in the current shell:
  export CLOUDFLARE_ACCOUNT_ID='your-account-id'
  export R2_ACCESS_KEY_ID='your-r2-access-key-id'
  export R2_SECRET_ACCESS_KEY='your-r2-secret-access-key'
Optional for bucket/dev-url automation:
  export CLOUDFLARE_API_TOKEN='scoped-cloudflare-api-token'
EOF
  if [[ "$DRY_RUN" != "1" ]]; then
    exit 2
  fi
fi

if [[ -n "${CLOUDFLARE_API_TOKEN:-}" ]]; then
  run "$WRANGLER r2 bucket create '$BUCKET' || true"
else
  printf 'No CLOUDFLARE_API_TOKEN set; skipping automatic bucket creation. Create bucket %s in the dashboard if needed.\n' "$BUCKET"
fi

export RCLONE_CONFIG_MI_R2_TYPE=s3
export RCLONE_CONFIG_MI_R2_PROVIDER=Cloudflare
export RCLONE_CONFIG_MI_R2_ACCESS_KEY_ID="$R2_ACCESS_KEY_ID"
export RCLONE_CONFIG_MI_R2_SECRET_ACCESS_KEY="$R2_SECRET_ACCESS_KEY"
export RCLONE_CONFIG_MI_R2_ENDPOINT="https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com"
run "$RCLONE copyto '$ISO' 'MI_R2:$BUCKET/$PREFIX/$ISO_NAME' --s3-upload-cutoff 64M --s3-chunk-size 64M --s3-no-check-bucket --progress"
run "$RCLONE copyto '$SHA256_FILE' 'MI_R2:$BUCKET/$PREFIX/$SHA256_NAME' --s3-no-check-bucket"
run "$RCLONE copyto '$SHA512_FILE' 'MI_R2:$BUCKET/$PREFIX/$SHA512_NAME' --s3-no-check-bucket"
run "$RCLONE copyto '$SIG_FILE' 'MI_R2:$BUCKET/$PREFIX/$SIG_NAME' --s3-no-check-bucket"
run "$RCLONE ls 'MI_R2:$BUCKET/$PREFIX' --s3-no-check-bucket"

if [[ -n "${CLOUDFLARE_API_TOKEN:-}" ]]; then
  run "$WRANGLER r2 bucket dev-url enable '$BUCKET' || true"
  run "$WRANGLER r2 bucket dev-url get '$BUCKET'"
else
  printf 'No CLOUDFLARE_API_TOKEN set; enable the bucket public r2.dev URL in Cloudflare dashboard, then rerun with MI_LINUX_R2_PUBLIC_BASE.\n'
fi

if [[ "$UPDATE_WEBSITE" == "1" ]]; then
  if [[ -z "$PUBLIC_BASE" ]]; then
    echo "UPDATE_WEBSITE=1 requires MI_LINUX_R2_PUBLIC_BASE, e.g. https://pub-xxxx.r2.dev" >&2
    exit 3
  fi
  OLD_BASE='https://manncloud.mannindustries.org/downloads/mi-linux/founder-preview'
  NEW_BASE="${PUBLIC_BASE%/}/$PREFIX"
  for f in "$WEBSITE_DIR"/*.html; do
    [[ -f "$f" ]] || continue
    cp -a "$f" "$f.pre-r2.$(date +%Y%m%d%H%M%S).bak"
    python3 - "$f" "$OLD_BASE" "$NEW_BASE" <<'PY'
import sys
p, old, new = sys.argv[1:]
s = open(p, encoding='utf-8').read()
s = s.replace(old, new)
open(p, 'w', encoding='utf-8').write(s)
PY
  done
  printf 'Website links updated from %s to %s\n' "$OLD_BASE" "$NEW_BASE"
else
  printf 'Website links not changed. Set UPDATE_WEBSITE=1 and MI_LINUX_R2_PUBLIC_BASE after confirming the public R2 URL.\n'
fi
