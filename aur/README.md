# AUR package: codex-desktop

This directory contains the AUR-style package files for ChatGPT Community on
Arch Linux and derivatives. The source application is OpenAI's official Linux
package; `ilysenko/codex-desktop-linux` verifies and repackages it as a native
pacman package.

The package is named `codex-desktop` for compatibility with its bundled update
manager. It declares `replaces=('codex-desktop-bin')`, so pacman can migrate
legacy installations without deleting `~/.codex`.

Build:

```bash
makepkg -s
```

Refresh metadata after editing `PKGBUILD`:

```bash
makepkg --printsrcinfo > .SRCINFO
```

Before publishing a version bump, resolve the current official package through
the signed stable index and update `pkgver`, architecture-specific URLs, and
SHA-256 values together. Do not use a `latest` URL as an AUR trust root.
