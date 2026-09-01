# MI Linux apt repository

Official endpoint: `https://apt.mannindustries.org`

Hosting decision: the public apt hostname is `apt.mannindustries.org`; the configured public HTTPS host serves the static signed repository from a deployment path such as `/srv/mi-linux-apt`.

Suites:

- `forky-founder` — default Founder Preview channel, curated and delayed about 3 months behind raw Debian Testing/Forky.
- `forky-tester` — current quarterly Testing/Forky channel, included in installed sources but commented out. It is intentionally indexed separately from `forky-founder` and only contains packages staged in `packages-tester/` or a configured tester source.

Installed source example:

```text
Types: deb
URIs: https://apt.mannindustries.org
Suites: forky-founder
Components: main
Signed-By: /usr/share/keyrings/mi-linux-archive-keyring.gpg
```

Generic publisher:

```bash
sudo ./scripts/publish-apt-repo.sh
```

The publisher:

1. Copies built `mi-linux-*.deb` packages from the local repo `packages/` directory into the `forky-founder` index by default.
2. Copies `forky-tester` packages only from `packages-tester/`, `TESTER_SRC_HOST`, or `TESTER_SRC_DIR`; founder packages do not automatically appear in tester.
3. Creates/uses a dedicated MI Linux archive signing key under the configured `GPGHOME` path.
4. Publishes the public key at `https://apt.mannindustries.org/mi-linux-archive-keyring.asc` and `.gpg`.
5. Generates separate `Packages`, `Packages.gz`, `Release`, `InRelease`, and `Release.gpg` for `forky-founder` and `forky-tester`.
6. Leaves raw Debian Testing/Forky out of the default installed MI Linux sources.

Installed systems also ship Debian snapshot sources for the operating-system packages. For the 2026-09-01 Founder cycle, `/etc/apt/sources.list.d/debian.sources` points at the 2026-06-01 Debian and Debian Security snapshots, while the current-quarter tester snapshot remains commented out for intentional opt-in only.

The HTTPS host should serve `apt.mannindustries.org` from the deployed apt repository root, for example `/srv/mi-linux-apt`.

DNS requirement before public HTTPS works:

- Add `apt.mannindustries.org` as an `A` or `CNAME` record pointing to the public repository host.

Verification after DNS is live:

```bash
curl -I https://apt.mannindustries.org/dists/forky-founder/InRelease
curl -fsSL https://apt.mannindustries.org/mi-linux-archive-keyring.asc | gpg --show-keys --fingerprint
```

Then run an isolated `apt-get update` test using the MI Linux keyring and `forky-founder` source before telling users the repo is public-ready.
