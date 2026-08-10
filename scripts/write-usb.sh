#!/bin/bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 path/to/image.iso /dev/sdX" >&2
  exit 2
fi

ISO=$1
DEV=$2

if [ ! -f "$ISO" ]; then
  echo "ISO not found: $ISO" >&2
  exit 1
fi

if [ ! -b "$DEV" ]; then
  echo "Target is not a block device: $DEV" >&2
  exit 1
fi

case "$DEV" in
  /dev/sd[a-z]|/dev/nvme[0-9]n[0-9]|/dev/mmcblk[0-9]) ;;
  *) echo "Refusing unusual target device path: $DEV" >&2; exit 1 ;;
esac

RM=$(lsblk -dn -o RM "$DEV" | tr -d ' ')
RO=$(lsblk -dn -o RO "$DEV" | tr -d ' ')
TYPE=$(lsblk -dn -o TYPE "$DEV" | tr -d ' ')
SIZE=$(stat -c%s "$ISO")

if [ "$TYPE" != "disk" ]; then
  echo "Refusing non-disk target: $DEV type=$TYPE" >&2
  exit 1
fi

if [ "$RM" != "1" ]; then
  echo "Refusing non-removable target: $DEV RM=$RM" >&2
  exit 1
fi

if [ "$RO" != "0" ]; then
  echo "Refusing read-only target: $DEV RO=$RO" >&2
  exit 1
fi

cat <<INFO
About to overwrite removable USB target:

ISO:    $ISO
Target: $DEV
Size:   $(numfmt --to=iec-i --suffix=B "$SIZE")

Target details:
$(lsblk -o NAME,PATH,SIZE,MODEL,VENDOR,TRAN,RM,RO,TYPE,MOUNTPOINTS,FSTYPE,LABEL "$DEV")
INFO

if [ "${OVERWRITE:-}" != "YES" ]; then
  echo "Set OVERWRITE=YES to write the image." >&2
  exit 3
fi

while read -r mountpoint; do
  [ -n "$mountpoint" ] || continue
  umount "$mountpoint"
done < <(lsblk -rn -o MOUNTPOINTS "$DEV" | sed '/^$/d')

sync

dd if="$ISO" of="$DEV" bs=4M status=progress conv=fsync,notrunc
sync

cmp -n "$SIZE" "$ISO" "$DEV"

echo "USB write verified: first $SIZE bytes of $DEV match $ISO"
lsblk -o NAME,PATH,SIZE,MODEL,VENDOR,TRAN,RM,RO,TYPE,MOUNTPOINTS,FSTYPE,LABEL "$DEV"
