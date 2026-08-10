# MI Linux apt repository

Official endpoint: `https://apt.mannindustries.org`

Hosting decision: the update server is MannCloud. The public apt hostname remains `apt.mannindustries.org`; MannCloud/Pi5 Caddy serves the static signed repository from `/opt/manncloud/apt-repo`.

Suites:

- `forky-founder` — default Founder Preview channel, curated and delayed about 3 months behind raw Debian Testing/Forky.
- `forky-tester` — testing/early-adopter channel, included in installed sources but commented out.

Installed source example:

```text
Types: deb
URIs: https://apt.mannindustries.org
Suites: forky-founder
Components: main
Signed-By: /usr/share/keyrings/mi-linux-archive-keyring.gpg
```

Current MannCloud publisher:

```bash
sudo ./scripts/publish-apt-repo-manncloud.sh
```

The publisher:

1. Copies built `mi-linux-*.deb` packages from MannPro `/home/robertlmann02/builds/mi-linux/packages`.
2. Creates/uses the dedicated MI Linux archive signing key under `/opt/manncloud/mi-linux-archive-gpg`.
3. Publishes the public key at `https://apt.mannindustries.org/mi-linux-archive-keyring.asc` and `.gpg`.
4. Generates `Packages`, `Packages.gz`, `Release`, `InRelease`, and `Release.gpg` for `forky-founder` and `forky-tester`.
5. Leaves raw Debian Testing/Forky out of the default installed MI Linux sources.

MannCloud Caddy must have a site block for `apt.mannindustries.org` serving `/srv/mi-linux-apt`, with Docker Compose mounting `./apt-repo:/srv/mi-linux-apt:ro` into the Caddy container.

DNS requirement before public HTTPS works:

- Add `apt.mannindustries.org` as an `A` or `CNAME` record pointing to the same public MannCloud endpoint as `manncloud.mannindustries.org`.
- Current MannCloud public A record observed during setup: `208.104.249.7`.

Verification after DNS is live:

```bash
curl -I https://apt.mannindustries.org/dists/forky-founder/InRelease
curl -fsSL https://apt.mannindustries.org/mi-linux-archive-keyring.asc | gpg --show-keys --fingerprint
```

Then run an isolated `apt-get update` test using the MI Linux keyring and `forky-founder` source before telling users the repo is public-ready.
