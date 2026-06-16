# codex-desktop-bin

Arch/CachyOS packaging for the latest Codex Desktop Linux build, powered by the
community conversion project <https://github.com/ilysenko/codex-desktop-linux>.

Special thanks to
[ilysenko/codex-desktop-linux](https://github.com/ilysenko/codex-desktop-linux)
for the core Linux conversion idea and implementation approach.

The package name is `codex-desktop-bin`, but the default install path is
local-build first: every user downloads the official upstream `Codex.dmg` and
builds the Linux package on their own machine. This avoids publicly
redistributing the converted Codex Desktop app payload.

For personal machines or trusted common environments, an explicit prebuilt mode
is available with `PREBUILT=1`.

## Beginner Install

If the package has been published to AUR:

```bash
yay -S codex-desktop-bin
```

or:

```bash
paru -S codex-desktop-bin
```

That default path builds locally. It may take several minutes and download a
large DMG plus Electron/runtime dependencies.

When yay/paru asks whether to clean build, choose clean build if you want to
force a fresh Codex DMG download. Otherwise the helper may reuse a cached DMG.

If you already have another Codex Desktop package installed, remove it first:

```bash
sudo pacman -R openai-codex-desktop
```

Keep your Codex CLI/config data. Do not delete `~/.codex` unless you explicitly
want to remove local Codex state.

## Fast Prebuilt Install

Prebuilt mode is opt-in:

```bash
PREBUILT=1 yay -S codex-desktop-bin
```

or:

```bash
PREBUILT=1 paru -S codex-desktop-bin
```

By default this pulls:

```text
https://github.com/JuckZ/codex-desktop-bin/releases/latest/download/codex-desktop-bin-x86_64.pkg.tar.zst
```

You can override it:

```bash
PREBUILT=1 PREBUILT_URL=https://example.com/codex-desktop-bin-x86_64.pkg.tar.zst yay -S codex-desktop-bin
```

For stricter verification:

```bash
PREBUILT=1 PREBUILT_SHA256=<sha256> yay -S codex-desktop-bin
```

Only use prebuilt mode for artifacts you trust.

## Updating Later

For normal users:

```bash
yay -S codex-desktop-bin
```

When prompted, choose a clean build to force a fresh local conversion.

For fast trusted installs:

```bash
PREBUILT=1 yay -S codex-desktop-bin
```

The installed package includes the upstream update manager by default unless it
is built with `PACKAGE_WITH_UPDATER=0`.

## Manual Local Build

Install build dependencies:

```bash
sudo pacman -S --needed git nodejs npm python 7zip curl unzip zstd rust base-devel
```

Build:

```bash
./scripts/build-latest.sh
```

Install the generated package:

```bash
sudo pacman -U dist/codex-desktop-bin-latest.pkg.tar.zst
```

## Build Options

```bash
UPSTREAM_REF=main ./scripts/build-latest.sh
MAX_BUILD_THREADS=8 ./scripts/build-latest.sh
PACKAGE_WITH_UPDATER=0 ./scripts/build-latest.sh
OUTPUT_DIR=/tmp/codex-dist ./scripts/build-latest.sh
```

Supported environment variables:

- `UPSTREAM_URL`: upstream wrapper repository URL.
- `UPSTREAM_REF`: upstream branch, tag, or commit. Defaults to `main`.
- `WORK_DIR`: local checkout cache. Defaults to `.work/codex-desktop-linux`.
- `OUTPUT_DIR`: package output directory. Defaults to `dist`.
- `PACKAGE_NAME`: package name. Defaults to `codex-desktop-bin`.
- `PACKAGE_DISPLAY_NAME`: desktop display name. Defaults to `Codex Desktop`.
- `PACKAGE_WITH_UPDATER`: include upstream update manager. Defaults to `1`.
- `MAX_BUILD_THREADS`: build/compression threads. Defaults to `nproc`.

## AUR Files

`aur/PKGBUILD` is the AUR-ready default:

- `PREBUILT=0` or unset: local build from upstream DMG.
- `PREBUILT=1`: install a trusted prebuilt package artifact.

Refresh `.SRCINFO` after editing the PKGBUILD:

```bash
cd aur
makepkg --printsrcinfo > .SRCINFO
```

Submit/push `aur/PKGBUILD` and `aur/.SRCINFO` to:

```text
ssh://aur@aur.archlinux.org/codex-desktop-bin.git
```

## GitHub Actions

The manual workflow `.github/workflows/build.yml` can build the package in an
Arch Linux container. Artifact upload is disabled by default.

Publishing prebuilt artifacts is convenient, but it redistributes the converted
Codex Desktop payload. Keep local-build as the public default unless you have
cleared that distribution question.

See [docs/DISTRIBUTION.md](docs/DISTRIBUTION.md).

## Disclaimer

This is an unofficial community project and is not affiliated with, endorsed by,
or supported by OpenAI. OpenAI, Codex, and related names/assets belong to their
respective rights holders.

Local build is the public default because public prebuilt artifacts may
redistribute converted Codex Desktop payload from the upstream macOS DMG.
Prebuilt mode is opt-in and should only be used for artifacts you trust.

Rights holders can request review or removal through a GitHub issue or the
maintainer email listed in the AUR package.

See [DISCLAIMER.md](DISCLAIMER.md) for the full disclaimer.
