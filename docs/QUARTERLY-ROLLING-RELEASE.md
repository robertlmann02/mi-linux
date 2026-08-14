# MI Linux quarterly rolling release policy

MI Linux uses a quarterly delayed rolling-release model.

## Cadence

- First automated quarterly update target: 2026-09-01.
- Recurring months: March, June, September, December.
- Release day: the 1st day of the quarter month.
- Default channel: `forky-founder`.
- Early tester channel: `forky-tester`.

## Three-month delay rule

Each quarterly MI Linux release is based on Debian Testing/Forky package state from approximately three months before the release date.

Examples:

- 2026-09-01 release uses a target Debian snapshot date around 2026-06-01.
- 2026-12-01 release uses a target Debian snapshot date around 2026-09-01.
- 2027-03-01 release uses a target Debian snapshot date around 2026-12-01.

This keeps MI Linux rolling, but not raw rolling. Users get a moving base with time for upstream breakage to be discovered before the packages reach the default Founder channel.

## Kernel policy

MI Linux should track the latest stable kernel that satisfies all of these release gates:

1. Supports Secure Boot on the target MI Linux install path.
2. Supports Waydroid requirements:
   - Android binder IPC.
   - binderfs.
3. Works on x86_64 hardware targeted by MI Linux.
4. Can be updated through the MI Linux/Debian apt flow without forcing unsigned or unverified kernel installation for normal users.

If the newest upstream stable kernel does not satisfy Secure Boot and Waydroid together in the MI Linux packaging path, the automation must choose the newest available stable kernel that does satisfy both gates and record the reason.

## Automation behavior

Quarterly automation must:

1. Compute the target delayed snapshot date: release date minus three months.
2. Generate a release plan under `out/quarterly-release/YYYY-MM-DD/`.
3. Check `https://apt.mannindustries.org` and current MI Linux repository metadata.
4. Check Debian/Forky package metadata for candidate kernel packages.
5. Prefer the newest stable kernel candidate that supports Secure Boot and Waydroid/binder requirements.
6. Rebuild or republish MI Linux package metadata only after checks pass.
7. Keep `forky-tester` available for early validation.
8. Promote to `forky-founder` only after metadata/signing/client update checks pass.
9. Produce a report with the selected snapshot date, kernel decision, package count, signature verification result, and any blockers.

## Human safety rule

Automation may prepare, build, sign, and publish routine repository metadata/packages when validation passes. It must not hide blockers. If Secure Boot support, Waydroid support, signing, or apt client update verification fails, the automation must stop and leave the current public update channel untouched.
