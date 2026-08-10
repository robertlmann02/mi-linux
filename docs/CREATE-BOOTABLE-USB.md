# Create a bootable MI Linux USB from GitHub

This guide explains how to download MI Linux from GitHub and write it to a USB drive.

Writing an ISO erases the whole USB drive. Back up anything important on the USB before you start.

## What you need

- A 16 GB or larger USB drive
- The MI Linux `.iso` file from the GitHub Release notes / MannCloud ISO link
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
4. Download the ISO from the MannCloud ISO link in the release notes:

   ```text
   https://manncloud.mannindustries.org/s/Zn5m6Sm6syjb2A6/download
   ```

5. Download the matching `.sha256` and `.sha512` files from the GitHub release assets or these MannCloud checksum links:

   ```text
   https://manncloud.mannindustries.org/s/zA73PDfyYr8jxkj/download
   https://manncloud.mannindustries.org/s/JBrpKra4KnyfsiZ/download
   ```

6. Download the GPG signature when it is provided. The ISO is hosted on MannCloud because the current Founder Preview ISO is larger than GitHub Releases' single-file asset limit.

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

Choose the section for the computer you are using to create the USB. You can create the USB on a Windows PC, a Mac, or a Linux computer.

### PC users: Windows with Rufus

1. Download Rufus from `https://rufus.ie/`.
2. Insert the USB drive.
3. Open Rufus.
4. Select the MI Linux `.iso` file.
5. Select the USB drive.
6. Click **Start**.
7. If Rufus asks about ISO mode or DD mode, use the recommended/default option first.
8. Wait for Rufus to finish, then safely eject the USB.

### PC users: Windows with balenaEtcher

Use this if you prefer a simpler Windows tool than Rufus.

1. Download balenaEtcher from `https://etcher.balena.io/`.
2. Insert the USB drive.
3. Open Etcher.
4. Select the MI Linux `.iso` file.
5. Select the USB drive.
6. Click **Flash**.
7. Wait for validation to finish, then safely eject the USB.

### Mac users: macOS with balenaEtcher

Use this if you are creating the MI Linux USB from a Mac. MI Linux is currently built for x86_64 PCs. A Mac can be used to create the USB, but Apple Silicon Macs are not a supported MI Linux install target for this first release.

1. Download balenaEtcher from `https://etcher.balena.io/`.
2. Insert the USB drive.
3. Open Etcher.
4. Select the MI Linux `.iso` file.
5. Select the USB drive.
6. Click **Flash**.
7. Enter your Mac password if macOS asks for permission to write the USB.
8. Wait for validation to finish.
9. Safely eject the USB from Finder or Disk Utility.
10. Move the USB to the PC where you want to boot or install MI Linux.

### Mac users: macOS command-line option

Most Mac users should use balenaEtcher. Advanced users can write the USB from Terminal. This erases the target disk.

1. Insert the USB drive.
2. Find the disk number:

   ```bash
   diskutil list
   ```

3. Unmount the USB disk, replacing `N` with the correct disk number:

   ```bash
   diskutil unmountDisk /dev/diskN
   ```

4. Write the ISO, replacing `N` and the ISO path. Use `rdiskN` for faster raw writing:

   ```bash
   sudo dd if=~/Downloads/mi-linux-forky-founder-amd64.iso of=/dev/rdiskN bs=4m status=progress
   sync
   ```

5. Eject the USB:

   ```bash
   diskutil eject /dev/diskN
   ```

### Linux users: GNOME Disks

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

### Boot on a Windows PC or standard PC

1. Leave the USB inserted.
2. Reboot the computer.
3. Open the boot menu. Common keys are `F12`, `F11`, `F10`, `Esc`, or `Del`, depending on the computer.
4. Choose the USB drive. It may appear as the USB brand name, `UEFI: USB`, or `USB HDD`.
5. Boot into the MI Linux live desktop.
6. Try the system first or click **Install MI Linux** to start Calamares.

### Boot on an Intel Mac

MI Linux is currently an x86_64 release. Intel Macs may boot it, but Apple Silicon Macs are not supported as an install target for this first release.

1. Leave the USB inserted.
2. Shut down or restart the Mac.
3. Hold the **Option** key while the Mac starts.
4. Choose the USB boot option, often shown as **EFI Boot**.
5. Boot into the MI Linux live desktop.
6. Try the system first or click **Install MI Linux** to start Calamares.

## Troubleshooting

- If the USB does not boot, try another USB port.
- If the computer has Secure Boot settings, make sure Secure Boot is enabled for testing MI Linux Secure Boot support.
- If the USB writer fails, re-download the ISO and verify the checksum again.
- If Rufus gives multiple write options, try DD mode if the default mode does not boot.
- If Ventoy does not boot the ISO correctly, try a direct-written USB instead.
