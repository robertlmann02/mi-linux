# Release Checklist

- Build ISO reproducibly with live-build
- Boot ISO in VM
- Verify live desktop branding
- Verify Calamares install
- Verify installed apt sources use `forky-founder` and commented `forky-tester`
- Verify MI Linux archive keyring
- Verify Update Manager
- Verify Timeshift prompt path
- Verify UFW and security timers
- Verify Waydroid-ready kernel: binder IPC, binderfs, Secure Boot signing path
- Verify SHA256, SHA512, and GPG signature
- Verify website download links
- Publish GitHub Release
