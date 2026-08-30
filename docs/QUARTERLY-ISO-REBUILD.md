# MI Linux quarterly ISO rebuild automation

MI Linux rebuilds a fresh candidate ISO every three months so the install media picks up the quarterly update set.

## Schedule

The operational timer runs on MannsPi5Ai on the 2nd day of March, June, September, and December at 04:30 local time, with `Persistent=true` so a missed run starts after the machine comes back online.

The timer intentionally runs after the quarterly update target day. That gives the package/update automation time to publish the quarterly set first, then the ISO rebuild pulls `origin/main` and bakes those updates into a new candidate image.

## Runner and builder

- Timer/runner host: MannsPi5Ai / Pi5.
- ISO builder host: MannMiniPC, reached over SSH as `robertlmann02@mannminipc.local`.
- Builder workspace: `/home/robertlmann02/mi-linux-build/mi-linux`.

The ISO build must happen on MannMiniPC because MI Linux publishes an amd64 image and MannsPi5Ai is ARM64. MannMiniPC is x86_64 and can take the quarterly automatic build time without tying up MannPro.

## Script

Run manually from MannsPi5Ai:

```bash
/home/robertlmann02/mi-linux/scripts/quarterly-iso-rebuild.sh
```

Useful overrides:

```bash
MI_LINUX_RELEASE_DATE=2026-09-01 /home/robertlmann02/mi-linux/scripts/quarterly-iso-rebuild.sh
MI_LINUX_BUILDER_HOST=mannminipc.local /home/robertlmann02/mi-linux/scripts/quarterly-iso-rebuild.sh
```

## What the script does

1. Computes the quarterly release date.
2. Fetches `origin/main` so pushed quarterly recipe/update changes are included.
3. Verifies the builder is reachable and `x86_64`.
4. Clones or resets the MannMiniPC builder workspace to `origin/main`.
5. Runs `scripts/validate-tree.sh`.
6. Runs `scripts/mi-linux-quarterly-update.py --mode prepare` for the release date.
7. Runs live-build clean/config/build.
8. Stores the candidate ISO and checksums under:
   - MannMiniPC: `out/quarterly-iso/YYYY-MM-DD/`
   - Pi5: `/home/robertlmann02/mi-linux-quarterly-candidates/YYYY-MM-DD/`
   - MannCloud candidate directory, when Pi5 passwordless sudo is available: `/opt/manncloud/downloads/mi-linux/quarterly-candidates/YYYY-MM-DD/`
9. Verifies SHA256 and SHA512 after copying back to Pi5.

## Safety rule

This automation creates a verified candidate ISO. It does not replace the public stable Founder Preview download name by itself. Public replacement still needs release verification: VM boot, desktop branding, Calamares install, installed apt sources, Secure Boot/Waydroid kernel checks, checksums/signature, website links, and GitHub Release update.

If MannMiniPC is offline, SSH fails, validation fails, live-build fails, or checksums fail, the script exits non-zero and leaves the current public ISO untouched.
