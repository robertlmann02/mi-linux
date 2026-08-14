#!/usr/bin/env python3
"""MI Linux quarterly delayed rolling-release automation helper.

This script is intentionally conservative. It computes the delayed snapshot target,
checks the public update server, verifies signed apt metadata, and writes an
operator report. Publishing/rebuilding can be layered on top only when these gates
stay green.
"""
from __future__ import annotations

import argparse
import datetime as dt
import gzip
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import urllib.request
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
OUT_ROOT = REPO_ROOT / "out" / "quarterly-release"
APT_BASE = "https://apt.mannindustries.org"
KEY_FP = "0094056963428AE05D79A4DB027156E99ED09243"
SUITES = ["forky-founder", "forky-tester"]


def run(cmd: list[str], *, input_bytes: bytes | None = None, timeout: int = 120) -> dict:
    p = subprocess.run(cmd, input=input_bytes, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=timeout)
    return {"cmd": cmd, "returncode": p.returncode, "output": p.stdout.decode("utf-8", "replace")}


def fetch(url: str, timeout: int = 30) -> bytes:
    req = urllib.request.Request(url, headers={"User-Agent": "mi-linux-quarterly-update/1.0"})
    with urllib.request.urlopen(req, timeout=timeout) as r:
        return r.read()


def subtract_months(day: dt.date, months: int) -> dt.date:
    month = day.month - months
    year = day.year
    while month <= 0:
        month += 12
        year -= 1
    # Release dates are the first of the month; keep day clamped for safety.
    last = [31, 29 if year % 4 == 0 and (year % 100 != 0 or year % 400 == 0) else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month - 1]
    return dt.date(year, month, min(day.day, last))


def quarter_name(day: dt.date) -> str:
    return f"{day.year}Q{((day.month - 1) // 3) + 1}"


def public_repo_checks() -> dict:
    result: dict[str, object] = {"base": APT_BASE, "suites": {}}
    key_gpg = fetch(f"{APT_BASE}/mi-linux-archive-keyring.gpg")
    key_asc = fetch(f"{APT_BASE}/mi-linux-archive-keyring.asc")
    result["key_gpg_bytes"] = len(key_gpg)
    result["key_asc_bytes"] = len(key_asc)
    with tempfile.TemporaryDirectory() as td:
        t = Path(td)
        key = t / "key.gpg"
        key.write_bytes(key_gpg)
        for suite in SUITES:
            release = fetch(f"{APT_BASE}/dists/{suite}/Release")
            release_gpg = fetch(f"{APT_BASE}/dists/{suite}/Release.gpg")
            inrelease = fetch(f"{APT_BASE}/dists/{suite}/InRelease")
            packages_gz = fetch(f"{APT_BASE}/dists/{suite}/main/binary-amd64/Packages.gz")
            packages = gzip.decompress(packages_gz).decode("utf-8", "replace")
            package_names = re.findall(r"^Package: (.+)$", packages, re.M)
            (t / f"{suite}.Release").write_bytes(release)
            (t / f"{suite}.Release.gpg").write_bytes(release_gpg)
            sig = run(["gpgv", "--keyring", str(key), str(t / f"{suite}.Release.gpg"), str(t / f"{suite}.Release")])
            result["suites"][suite] = {
                "release_bytes": len(release),
                "inrelease_bytes": len(inrelease),
                "packages_gz_bytes": len(packages_gz),
                "package_count": len(package_names),
                "packages": package_names,
                "signature_ok": sig["returncode"] == 0,
                "signature_output": sig["output"],
            }
    return result


def apt_client_check() -> dict:
    with tempfile.TemporaryDirectory() as td:
        root = Path(td)
        for rel in [
            "etc/apt/sources.list.d", "etc/apt/trusted.gpg.d", "etc/apt/keyrings", "etc/apt/preferences.d",
            "var/lib/apt/lists/partial", "var/cache/apt/archives/partial", "var/lib/dpkg", "etc/apt/apt.conf.d",
        ]:
            (root / rel).mkdir(parents=True, exist_ok=True)
        (root / "var/lib/dpkg/status").write_text("")
        (root / "etc/apt/keyrings/mi-linux-archive-keyring.gpg").write_bytes(fetch(f"{APT_BASE}/mi-linux-archive-keyring.gpg"))
        (root / "etc/apt/sources.list.d/mi-linux.sources").write_text(
            "Types: deb\n"
            f"URIs: {APT_BASE}\n"
            "Suites: forky-founder\n"
            "Components: main\n"
            "Architectures: amd64\n"
            f"Signed-By: {root}/etc/apt/keyrings/mi-linux-archive-keyring.gpg\n"
        )
        common = [
            "-o", f"Dir={root}",
            "-o", "Dir::Etc::sourcelist=sources.list",
            "-o", "Dir::Etc::sourceparts=sources.list.d",
            "-o", "Dir::Etc::trusted=trusted.gpg",
            "-o", "Dir::Etc::trustedparts=trusted.gpg.d",
            "-o", f"Dir::State::status={root}/var/lib/dpkg/status",
            "-o", "Apt::Architecture=amd64",
            "-o", "Debug::NoLocking=1",
        ]
        update = run(["apt-get", *common, "update"], timeout=180)
        policy = run(["apt-cache", *common, "policy", "mi-linux-branding", "mi-linux-archive-keyring"], timeout=120)
        return {"update_ok": update["returncode"] == 0, "update_output": update["output"], "policy_output": policy["output"]}


def kernel_policy_check() -> dict:
    # We can check the running/build host config when available. The actual quarterly
    # release gate should run this on the candidate build image/kernel before promotion.
    uname = run(["uname", "-r"])
    kernel = uname["output"].strip()
    cfg_paths = [Path(f"/boot/config-{kernel}"), Path("/proc/config.gz")]
    cfg_text = ""
    source = "unavailable"
    if cfg_paths[0].exists():
        cfg_text = cfg_paths[0].read_text(errors="replace")
        source = str(cfg_paths[0])
    elif cfg_paths[1].exists():
        cfg_text = gzip.decompress(cfg_paths[1].read_bytes()).decode("utf-8", "replace")
        source = str(cfg_paths[1])
    binder = "CONFIG_ANDROID_BINDER_IPC=y" in cfg_text or "CONFIG_ANDROID_BINDER_IPC=m" in cfg_text
    binderfs = "CONFIG_ANDROID_BINDERFS=y" in cfg_text or "CONFIG_ANDROID_BINDERFS=m" in cfg_text
    secureboot_tools = shutil.which("mokutil") is not None or Path("/sys/firmware/efi").exists()
    return {
        "running_kernel": kernel,
        "config_source": source,
        "binder_ipc_config_present": binder,
        "binderfs_config_present": binderfs,
        "secure_boot_probe_available": secureboot_tools,
        "policy": "select newest stable kernel that passes binder/binderfs and Secure Boot gates on the release candidate image",
    }


def write_report(release_date: dt.date, mode: str) -> tuple[Path, dict]:
    snapshot_date = subtract_months(release_date, 3)
    out = OUT_ROOT / release_date.isoformat()
    out.mkdir(parents=True, exist_ok=True)
    checks = {
        "generated_at": dt.datetime.now(dt.timezone.utc).isoformat(),
        "mode": mode,
        "release_date": release_date.isoformat(),
        "quarter": quarter_name(release_date),
        "delayed_snapshot_date": snapshot_date.isoformat(),
        "snapshot_policy": "release date minus three months",
        "apt_repository": public_repo_checks(),
        "apt_client": apt_client_check(),
        "kernel_policy": kernel_policy_check(),
    }
    checks["gates_green"] = bool(
        all(s["signature_ok"] for s in checks["apt_repository"]["suites"].values())
        and checks["apt_client"]["update_ok"]
    )
    report = out / "quarterly-update-report.json"
    report.write_text(json.dumps(checks, indent=2, sort_keys=True))
    md = out / "quarterly-update-report.md"
    pkgs = checks["apt_repository"]["suites"]["forky-founder"]["packages"]
    md.write_text(
        f"# MI Linux quarterly update report: {release_date.isoformat()}\n\n"
        f"- Quarter: {checks['quarter']}\n"
        f"- Delayed Debian snapshot target: {snapshot_date.isoformat()}\n"
        f"- Default suite: forky-founder\n"
        f"- Tester suite: forky-tester\n"
        f"- Apt client update gate: {'PASS' if checks['apt_client']['update_ok'] else 'FAIL'}\n"
        f"- Repository signature gates: {'PASS' if all(s['signature_ok'] for s in checks['apt_repository']['suites'].values()) else 'FAIL'}\n"
        f"- Overall gates: {'PASS' if checks['gates_green'] else 'FAIL'}\n\n"
        "## Current published packages\n\n"
        + "\n".join(f"- `{p}`" for p in pkgs)
        + "\n\n## Kernel policy\n\n"
        f"Running/build host kernel observed: `{checks['kernel_policy']['running_kernel']}`.\n\n"
        "Quarterly promotion must use the newest stable kernel candidate that passes binder/binderfs and Secure Boot gates on the release candidate image.\n"
    )
    return report, checks


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--release-date", help="Quarterly release date, YYYY-MM-DD. Defaults to today.")
    ap.add_argument("--mode", default="prepare", choices=["prepare", "verify-only"])
    args = ap.parse_args()
    release_date = dt.date.fromisoformat(args.release_date) if args.release_date else dt.date.today()
    report, checks = write_report(release_date, args.mode)
    print(report)
    print("gates_green=", checks["gates_green"])
    return 0 if checks["gates_green"] else 2


if __name__ == "__main__":
    raise SystemExit(main())
