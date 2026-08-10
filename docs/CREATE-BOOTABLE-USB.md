# Create a bootable MI Linux USB from GitHub

This guide explains how to download MI Linux from GitHub and write it to a USB drive.

Writing an ISO erases the whole USB drive. Back up anything important on the USB before you start.

## What you need

- A 16 GB or larger USB drive
- The MI Linux `.iso` file from GitHub Releases
- The matching checksum files, when published:
  - `.sha256`
  - `.sha512`
  - `.sig` / GPG signature
- A USB writing tool, such as Rufus, balenaEtcher, GNOME Disks, Ventoy, or the included Linux command-line helper

## Step 1: Download from GitHub

1. Open the MI Linux GitHub repository:

   ```text
   https://github.com/robertlmann02/mi-linux
   ```

2. Click **Releases** on the right side of the GitHub page.
3. Open the latest MI Linux Forky Founder release.
4. Download the `.iso` file.
5. Download the matching `.sha256`, `.sha512`, and signature files if they are attached to the release.

If no release assets are published yet, the ISO is not publicly downloadable from GitHub yet. The repository still contains the build source and USB helper script for people building from source.

## Step 2: Verify the download

From Linux or macOS, open a terminal in the folder where you downloaded the ISO and run:

```bash
sha256sum mi-linux-forky-founder-amd64.iso
sha512sum mi-linux-forky-founder-amd64.iso
```

Compare the output with the published `.sha256` and `.sha512` files.

If a GPG signature is published, verify it with the MI Linux release signing key:

```bash
gpg --verify mi-linux-forky-founder-amd64.iso.sig mi-linux-forky-founder-amd64.iso
```

Only continue if the checksums and signature match the published release information.

## Step 3: Write the USB with a graphical tool

### Windows: Rufus

1. Download Rufus from `https://rufus.ie/`.
2. Insert the USB drive.
3. Open Rufus.
4. Select the MI Linux `.iso` file.
5. Select the USB drive.
6. Click **Start**.
7. If Rufus asks about ISO mode or DD mode, use the recommended/default option first.
8. Wait for Rufus to finish, then safely eject the USB.

### Windows, macOS, or Linux: balenaEtcher

1. Download balenaEtcher from `https://etcher.balena.io/`.
2. Insert the USB drive.
3. Open Etcher.
4. Select the MI Linux `.iso` file.
5. Select the USB drive.
6. Click **Flash**.
7. Wait for validation to finish, then safely eject the USB.

### Linux: GNOME Disks

1. Insert the USB drive.
2. Open **Disks**.
3. Select the USB drive from the left side.
4. Open the menu and choose **Restore Disk Image**.
5. Select the MI Linux `.iso` file.
6. Confirm the target USB drive.
7. Start the restore and wait for it to finish.
8. Safely eject the USB.

### Advanced users: Ventoy

Ventoy lets one USB hold multiple ISO files.

1. Install Ventoy to the USB drive from `https://www.ventoy.net/`.
2. Copy the MI Linux `.iso` file onto the Ventoy USB.
3. Boot from the USB and select MI Linux from the Ventoy menu.

Ventoy is convenient for testing, but a direct-written USB with Rufus, Etcher, GNOME Disks, or the repo helper is the simplest path for first installs.

## Step 4: Write the USB from Linux using the GitHub repo helper

The MI Linux repository includes a safer Linux helper script:

```text
scripts/write-usb.sh
```

It checks that the target is a removable disk, shows the target details, requires `OVERWRITE=YES`, writes the ISO, and byte-compares the USB back against the ISO.

### Clone the repository

```bash
git clone https://github.com/robertlmann02/mi-linux.git
cd mi-linux
```

### Find the USB device

Insert the USB and run:

```bash
lsblk -o NAME,PATH,SIZE,MODEL,VENDOR,TRAN,RM,RO,TYPE,MOUNTPOINTS,FSTYPE,LABEL
```

Look for the removable USB disk, usually something like `/dev/sdb`.

Use the whole disk path, not a partition:

Correct example:

```text
/dev/sdb
```

Wrong example:

```text
/dev/sdb1
```

### Run the helper script

Replace `/path/to/mi-linux-forky-founder-amd64.iso` and `/dev/sdX` with your real ISO path and USB disk path:

```bash
OVERWRITE=YES sudo -E ./scripts/write-usb.sh /path/to/mi-linux-forky-founder-amd64.iso /dev/sdX
```

Example:

```bash
OVERWRITE=YES sudo -E ./scripts/write-usb.sh ~/Downloads/mi-linux-forky-founder-amd64.iso /dev/sdb
```

When it finishes, the script should print:

```text
USB write verified
```

That means the bytes written to the USB match the ISO.

## Step 5: Boot from the USB

1. Leave the USB inserted.
2. Reboot the computer.
3. Open the boot menu. Common keys are `F12`, `F11`, `F10`, `Esc`, or `Del`, depending on the computer.
4. Choose the USB drive.
5. Boot into the MI Linux live desktop.
6. Try the system first or click **Install MI Linux** to start Calamares.

## Troubleshooting

- If the USB does not boot, try another USB port.
- If the computer has Secure Boot settings, make sure Secure Boot is enabled for testing MI Linux Secure Boot support.
- If the USB writer fails, re-download the ISO and verify the checksum again.
- If Rufus gives multiple write options, try DD mode if the default mode does not boot.
- If Ventoy does not boot the ISO correctly, try a direct-written USB instead.
