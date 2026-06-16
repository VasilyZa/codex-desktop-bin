# AUR package: codex-desktop-bin

This directory contains the AUR package files.

This package is based on the Linux conversion workflow from
[ilysenko/codex-desktop-linux](https://github.com/ilysenko/codex-desktop-linux).
This project is unofficial and is not affiliated with OpenAI.

Default install:

```bash
yay -S codex-desktop-bin
```

or:

```bash
paru -S codex-desktop-bin
```

Default behavior is local-build. It downloads the official Codex DMG and builds
the Linux package on the user's machine.

When yay/paru asks whether to clean build, choose clean build to force a fresh
Codex DMG download. Otherwise the helper may reuse its cached sources.

Fast trusted prebuilt mode:

```bash
PREBUILT=1 yay -S codex-desktop-bin
```

Optional overrides:

```bash
PREBUILT=1 PREBUILT_URL=https://example.com/codex-desktop-bin-x86_64.pkg.tar.zst yay -S codex-desktop-bin
PREBUILT=1 PREBUILT_SHA256=<sha256> yay -S codex-desktop-bin
```

Update `.SRCINFO` after changing `PKGBUILD`:

```bash
makepkg --printsrcinfo > .SRCINFO
```

Publish to AUR:

```bash
git clone ssh://aur@aur.archlinux.org/codex-desktop-bin.git
cp PKGBUILD .SRCINFO codex-desktop-bin/
cd codex-desktop-bin
git add PKGBUILD .SRCINFO
git commit -m "Initial import"
git push
```

Before publishing, review the root `DISCLAIMER.md`. If a rights holder requests
removal, disable prebuilt artifacts and/or remove the AUR package as appropriate.
