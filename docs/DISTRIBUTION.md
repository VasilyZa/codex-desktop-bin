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

## Binary artifacts

A generated package contains OpenAI application binaries. The repository's MIT
license applies only to this project's packaging code and documentation; it
does not grant rights to redistribute OpenAI's payload. Keep public binary
publishing disabled unless the relevant distribution terms have been reviewed.

## Package migration

The runtime-compatible package identity is `codex-desktop`. It replaces the
historical `codex-desktop-bin` package in one pacman transaction. Package
removal and replacement preserve `~/.codex` and other user-owned state.
