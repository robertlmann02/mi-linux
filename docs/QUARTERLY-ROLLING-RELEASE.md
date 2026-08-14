# MI Linux quarterly rolling release policy

MI Linux uses a quarterly rolling-release model with two channels:

- `forky-founder` — default user channel, delayed about three months.
- `forky-tester` — current tester channel, updated quarterly without the three-month delay.

## Cadence

- First automated quarterly update target: 2026-09-01.
- Recurring months: March, June, September, December.
- Release day: the 1st day of the quarter month.
- Default installed channel: `forky-founder`.
- Optional early/current channel: `forky-tester`.

## Channel timing rules

Each quarterly MI Linux cycle has two package targets:

1. `forky-tester` tracks the current Debian Testing/Forky package state for that quarterly release date.
2. `forky-founder` tracks the Debian Testing/Forky package state from approximately three months before that release date.

Examples:

| Release date | `forky-tester` target | `forky-founder` target |
|---|---:|---:|
| 2026-09-01 | 2026-09-01 current Testing/Forky | 2026-06-01 delayed Testing/Forky |
| 2026-12-01 | 2026-12-01 current Testing/Forky | 2026-09-01 delayed Testing/Forky |
| 2027-03-01 | 2027-03-01 current Testing/Forky | 2026-12-01 delayed Testing/Forky |

This keeps MI Linux rolling, but not raw rolling for normal users. Testers can validate the current quarterly package set first; normal Founder-channel users get the same general stream after a three-month buffer.

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

1. Compute the tester target date: release date.
2. Compute the founder target date: release date minus three months.
3. Generate a release plan under `out/quarterly-release/YYYY-MM-DD/`.
4. Check `https://apt.mannindustries.org` and current MI Linux repository metadata.
5. Check Debian/Forky package metadata for candidate kernel packages.
6. Prefer the newest stable kernel candidate that supports Secure Boot and Waydroid/binder requirements.
7. Publish candidate/current packages to `forky-tester` first.
8. Promote only validated three-month-delayed packages to `forky-founder` after metadata/signing/client update checks pass.
9. Produce a report with the tester target date, founder target date, kernel decision, package counts, signature verification result, and any blockers.

## Human safety rule

Automation may prepare, build, sign, and publish routine repository metadata/packages when validation passes. It must not hide blockers. If Secure Boot support, Waydroid support, signing, or apt client update verification fails, the automation must stop and leave the current public update channel untouched.
