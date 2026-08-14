# Distribution notes

This repository is packaging automation for Arch/CachyOS. It uses
`ilysenko/codex-desktop-linux` to verify OpenAI's signed stable APT metadata,
validate the selected official Linux package, and build a pacman package.
OpenAI's preview documentation currently lists Ubuntu, Debian, and Fedora;
Arch/CachyOS support in this repository remains community-maintained.

## Source and trust model

- OpenAI's signed Linux `.deb` is the application source.
- The signature chain is pinned repository key → `InRelease` → `Packages`
  SHA-256 → package SHA-256.
- Upstream maintainer scripts are not executed; only the data payload is used.
- With no optional ASAR feature enabled, the official `resources/app.asar`
  remains byte-for-byte identical.
- The old macOS DMG conversion and its redistribution caveat no longer apply.

The AUR recipe pins a concrete upstream commit and official package hash. The
local latest-build script follows the signed stable index and records the
resolved version and digest inside the application build metadata.

## Prebuilt pacman repository

Successful release workflows publish the x86_64 package, its SHA-256 file,
build provenance, and `juckz.db` as assets of the latest GitHub Release. The
stable repository endpoint is:

```text
https://github.com/JuckZ/codex-desktop-bin/releases/latest/download
```

After the one-time repository setup, install or update with:

```bash
sudo pacman -Syu juckz/codex-desktop
```

The workflow runs after relevant changes to `main`, on manual dispatch, and on
a six-hour schedule. It publishes only when the signed OpenAI payload or the
packaging source differs from the latest release. Release assets currently
target x86_64; aarch64 remains a local-build path.

The pacman repository is not PGP-signed yet. The setup therefore configures
`SigLevel = Never`; transport uses HTTPS, while the repository database stores
the package SHA-256. Adding a stable offline-controlled signing key is required
before changing this to mandatory package and database signature validation.

## Binary artifacts and redistribution

A generated package contains OpenAI application binaries. The repository's MIT
license applies only to this project's packaging code and documentation; it
does not grant rights to redistribute OpenAI's payload. The repository owner
has elected to publish generated packages after reviewing and accepting that
separate redistribution risk. Downloaders receive no additional rights to the
OpenAI payload from this project's MIT license.

## Package migration

The runtime-compatible package identity is `codex-desktop`. It replaces the
historical `codex-desktop-bin` package in one pacman transaction. Package
removal and replacement preserve `~/.codex` and other user-owned state.
