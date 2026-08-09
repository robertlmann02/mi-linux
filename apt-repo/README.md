# MI Linux apt repository

Official endpoint: `https://apt.mannindustries.org`

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

Requirements before public release:

1. Generate a dedicated MI Linux archive signing key.
2. Ship the public key in `mi-linux-archive-keyring`.
3. Sign repository metadata.
4. Publish only curated packages/snapshots into `forky-founder`.
5. Keep raw Debian Testing/Forky out of default installed sources.
6. Publish release notes with snapshot date and known issues.
