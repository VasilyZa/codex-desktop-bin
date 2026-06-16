# codex-desktop-bin

Build the latest Codex Desktop Linux package for Arch/CachyOS from the upstream
community port at <https://github.com/ilysenko/codex-desktop-linux>.

This repository intentionally contains only automation, packaging templates, and
documentation. It does not commit or publish OpenAI Codex Desktop binaries by
default.

## What It Builds

Default package identity:

- Package name: `codex-desktop-bin`
- Install root: `/opt/codex-desktop-bin`
- Launcher: `/usr/bin/codex-desktop-bin`
- Desktop file: `/usr/share/applications/codex-desktop-bin.desktop`

The generated package is built by:

1. Cloning/updating `ilysenko/codex-desktop-linux`.
2. Downloading the latest upstream `Codex.dmg`.
3. Converting the macOS Electron app into a Linux Electron app.
4. Packaging the result as an Arch `.pkg.tar.zst`.

## Local Build

Install the normal Arch/CachyOS build dependencies first:

```bash
sudo pacman -S --needed nodejs npm python 7zip curl unzip zstd base-devel rust
```

Build the latest package:

```bash
./scripts/build-latest.sh
```

The package is written to `dist/`, with a `codex-desktop-bin-latest.pkg.tar.zst`
symlink and a SHA256 file.

Install it manually:

```bash
sudo pacman -U dist/codex-desktop-bin-latest.pkg.tar.zst
```

If another Codex Desktop package already owns the `codex://` desktop handler,
remove that package first. On my CachyOS machine the old package was:

```bash
sudo pacman -R openai-codex-desktop
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

## GitHub Actions

The manual workflow `.github/workflows/build.yml` can build the package on an
Arch Linux container. Artifact upload is disabled by default.

Do not publish public binary artifacts unless you have confirmed that
redistributing the converted Codex Desktop payload is allowed.

## AUR

`aur/` contains a draft `codex-desktop-bin` AUR template. It assumes a GitHub
Release artifact exists and installs that binary payload.

The safer public AUR route is to publish a source/build package that makes each
user build from the upstream DMG locally. A true `-bin` AUR package should only
be submitted after the binary redistribution question is resolved.

See [docs/DISTRIBUTION.md](docs/DISTRIBUTION.md) and [aur/README.md](aur/README.md).
