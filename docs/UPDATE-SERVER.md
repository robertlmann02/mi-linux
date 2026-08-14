# MI Linux Update Server

The MI Linux update server is live at:

```text
https://apt.mannindustries.org
```

It is a signed Debian-style apt repository hosted on MannCloud/Caddy.

## Channels

- `forky-founder` — default Founder Preview channel.
- `forky-tester` — early tester channel; use only for pre-release package testing.

## Deb822 source

Installed MI Linux systems should use:

```text
Types: deb
URIs: https://apt.mannindustries.org
Suites: forky-founder
Components: main
Signed-By: /usr/share/keyrings/mi-linux-archive-keyring.gpg
```

## Manual setup on a Debian/Forky test machine

```bash
sudo install -d -m 0755 /usr/share/keyrings
curl -fsSL https://apt.mannindustries.org/mi-linux-archive-keyring.gpg \
  | sudo tee /usr/share/keyrings/mi-linux-archive-keyring.gpg >/dev/null
sudo tee /etc/apt/sources.list.d/mi-linux.sources >/dev/null <<'EOF'
Types: deb
URIs: https://apt.mannindustries.org
Suites: forky-founder
Components: main
Signed-By: /usr/share/keyrings/mi-linux-archive-keyring.gpg
EOF
sudo apt update
apt policy mi-linux-branding mi-linux-archive-keyring
```

## Current Founder Preview packages

The repository currently publishes MI Linux package skeletons and branding packages:

- `mi-linux-archive-keyring`
- `mi-linux-branding`
- `mi-linux-default-settings`
- `mi-linux-gaming-meta`
- `mi-linux-gnome-theme`
- `mi-linux-update-manager`
- `mi-linux-wallpapers`
- `mi-linux-welcome`

## Verification

```bash
curl -I https://apt.mannindustries.org/dists/forky-founder/InRelease
curl -fsSL https://apt.mannindustries.org/mi-linux-archive-keyring.asc \
  | gpg --show-keys --fingerprint
```

A working client should fetch `forky-founder InRelease` and `forky-founder/main amd64 Packages` during `apt update`.
