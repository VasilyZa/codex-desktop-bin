# codex-desktop-bin

[English](README.md) | [简体中文](README.zh-CN.md)

Arch/CachyOS packaging for **ChatGPT Community**, built from OpenAI's signed
official Linux ChatGPT package through
[`ilysenko/codex-desktop-linux`](https://github.com/ilysenko/codex-desktop-linux).

Despite this repository's historical name, generated packages now use the
upstream-compatible package and command identity `codex-desktop`. This is
required by the bundled transactional updater. The package replaces the legacy
`codex-desktop-bin` package in one pacman transaction and preserves user data.

## What changed

OpenAI now publishes a native Linux package. This project no longer downloads
or converts `Codex.dmg`. The current build:

- verifies OpenAI's signed stable APT metadata and package SHA-256;
- extracts the official Linux Electron runtime and bundled tools;
- preserves `resources/app.asar` byte-for-byte when no optional feature is
  enabled;
- produces a native Arch package;
- includes the upstream transactional update manager and rollback support.

The installed desktop entry is **ChatGPT Community** so it remains distinct
from OpenAI's separate `chatgpt` package.

OpenAI currently documents the Linux app as a preview for supported Ubuntu,
Debian, and Fedora releases. Arch/CachyOS is not listed as a supported target,
so this repository remains the compatibility and pacman-packaging layer for
those systems. See the [official Linux app documentation](https://developers.openai.com/codex/linux/linux-app/).

## Install on Arch/CachyOS

Prebuilt x86_64 packages are published as GitHub Releases, then verified,
signed, and mirrored into the existing `JuckZ/arch-repo` pacman repository.
Configure its signing key and repository once:

```bash
curl -fsSL https://raw.githubusercontent.com/JuckZ/codex-desktop-bin/main/scripts/setup-pacman-repo.sh | sudo bash
```

Then install or update with the normal full-system upgrade transaction:

```bash
sudo pacman -Syu juckz/codex-desktop
```

The package is named `codex-desktop`; `codex-desktop-bin` is only the
historical repository name and legacy package identity. Avoid `pacman -Sy`
without `-u`, because Arch does not support partial upgrades.

The public repository requires package signatures from the JuckZ repository
key. See [the distribution notes](docs/DISTRIBUTION.md) for the verification
chain and binary redistribution notice.

## Build locally

Local building remains available for development, auditing, aarch64, or as a
fallback if a prebuilt release is unavailable.

Install build dependencies:

```bash
sudo pacman -S --needed base-devel curl dpkg git gnupg nodejs npm python rust
```

Build from the latest upstream commit and OpenAI's signed stable package:

```bash
./scripts/build-latest.sh
```

Install it, including automatic replacement of a legacy `codex-desktop-bin`
installation:

```bash
./scripts/install-local.sh
```

The migration does not delete `~/.codex`, which is shared application and CLI
state. Fully quit Codex Desktop before installing.

## Verify

```bash
pacman -Qi codex-desktop
codex-desktop --diagnose
systemctl --user status codex-update-manager.service --no-pager
codex-update-manager status --json
```

## Updating

For installations configured through the `juckz` repository, normal system
updates install new releases:

```bash
sudo pacman -Syu
```

The installed updater checks OpenAI's signed stable repository and rebuilds the
native package with the same feature selection:

```bash
codex-update-manager check-now
codex-update-manager status
```

To update explicitly by rebuilding this repository instead:

```bash
git pull --ff-only
./scripts/build-latest.sh
./scripts/install-local.sh
```

Useful build overrides:

```bash
UPSTREAM_REF=<branch-tag-or-commit> ./scripts/build-latest.sh
MAX_BUILD_THREADS=8 ./scripts/build-latest.sh
PACKAGE_WITH_UPDATER=0 ./scripts/build-latest.sh
OUTPUT_DIR=/tmp/codex-dist ./scripts/build-latest.sh
UPSTREAM_DEB=/path/to/chatgpt_amd64.deb ./scripts/build-latest.sh
```

## AUR files

`aur/PKGBUILD` is a reproducible AUR-style recipe pinned to a reviewed upstream
commit and a concrete official package version/hash. `pkgver` follows the UTC
build timestamp scheme used by the updater; `_chatgpt_ver` records the OpenAI
application version. When OpenAI publishes a new version, update both values,
both architecture hashes, and refresh:

```bash
cd aur
makepkg --printsrcinfo > .SRCINFO
```

The local `scripts/build-latest.sh` path intentionally follows the signed
stable metadata instead of a static version pin.

## Wayland

OpenAI's native Wayland support is experimental. The default XWayland path is
recommended first. To test native Wayland, add this line to
`~/.config/codex-desktop/electron-flags.conf`:

```text
--ozone-platform=wayland
```

## Acknowledgements

Thanks to the [Linux.do](https://linux.do/) community for providing a platform
and welcoming environment for discussion. The discussions and sharing there
have been a great help to this project.

## Disclaimer

This is an unofficial community packaging project. It is not affiliated with,
endorsed by, or supported by OpenAI. OpenAI, ChatGPT, Codex, and related assets
belong to their respective rights holders. See [DISCLAIMER.md](DISCLAIMER.md).
