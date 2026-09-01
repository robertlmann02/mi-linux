# MI Linux quarterly ISO rebuild automation

MI Linux rebuilds a fresh candidate ISO every three months so the install media picks up the quarterly update set.

## Schedule

Run the operational timer on your automation runner on the 2nd day of March, June, September, and December, after the quarterly package/update automation has had time to publish.

The timer intentionally runs after the quarterly update target day. That gives the package/update automation time to publish the quarterly set first, then the ISO rebuild pulls `origin/main` and bakes those updates into a new candidate image.

## Runner and builder

- Timer/runner host: an always-on automation host.
- ISO builder host: an `x86_64` Linux build host reachable over SSH.
- Builder workspace: a configurable checkout path such as `/srv/mi-linux-build/mi-linux`.

The ISO build should run on an `x86_64` machine because MI Linux publishes an amd64 image. The runner can be separate from the builder when the always-on automation host is a different architecture.

## Script

Run manually from the automation runner:

```bash
/path/to/mi-linux/scripts/quarterly-iso-rebuild.sh
```

Useful overrides:

```bash
MI_LINUX_RELEASE_DATE=2026-09-01 /path/to/mi-linux/scripts/quarterly-iso-rebuild.sh
MI_LINUX_BUILDER_HOST=builder.example.internal /path/to/mi-linux/scripts/quarterly-iso-rebuild.sh
```

## What the script does

1. Computes the quarterly release date.
2. Fetches `origin/main` so pushed quarterly recipe/update changes are included.
3. Verifies the builder is reachable and `x86_64`.
4. Clones or resets the builder workspace to `origin/main`.
5. Runs `scripts/validate-tree.sh`.
6. Runs `scripts/mi-linux-quarterly-update.py --mode prepare` for the release date.
7. Runs live-build clean/config/build.
8. Stores the candidate ISO and checksums under:
   - Build host: `out/quarterly-iso/YYYY-MM-DD/`
   - Automation runner: configured `MI_LINUX_LOCAL_CANDIDATE_ROOT/YYYY-MM-DD/`
   - Optional public-staging directory, when enabled: configured `MI_LINUX_PUBLIC_CANDIDATE_ROOT/YYYY-MM-DD/`
9. Verifies SHA256 and SHA512 after copying back to Pi5.

## Safety rule

This automation creates a verified candidate ISO. It does not replace the public stable Founder Preview download name by itself. Public replacement still needs release verification: VM boot, desktop branding, Calamares install, installed apt sources, Secure Boot/Waydroid kernel checks, checksums/signature, website links, and GitHub Release update.

If the build host is offline, SSH fails, validation fails, live-build fails, or checksums fail, the script exits non-zero and leaves the current public ISO untouched.
