#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

UPSTREAM_URL="${UPSTREAM_URL:-https://github.com/ilysenko/codex-desktop-linux.git}"
UPSTREAM_REF="${UPSTREAM_REF:-main}"
WORK_DIR="${WORK_DIR:-$REPO_ROOT/.work/codex-desktop-linux}"
OUTPUT_DIR="${OUTPUT_DIR:-$REPO_ROOT/dist}"
PACKAGE_NAME="${PACKAGE_NAME:-codex-desktop-bin}"
PACKAGE_DISPLAY_NAME="${PACKAGE_DISPLAY_NAME:-Codex Desktop}"
PACKAGE_COMMENT="${PACKAGE_COMMENT:-Run Codex Desktop on Linux}"
PACKAGE_WITH_UPDATER="${PACKAGE_WITH_UPDATER:-1}"

if [ -z "${MAX_BUILD_THREADS:-}" ]; then
  if command -v nproc >/dev/null 2>&1; then
    MAX_BUILD_THREADS="$(nproc)"
  else
    MAX_BUILD_THREADS="4"
  fi
fi

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  }
}

require_cmd git
require_cmd make
require_cmd makepkg
require_cmd curl
require_cmd 7z
require_cmd node
require_cmd npm
require_cmd cargo

mkdir -p "$(dirname "$WORK_DIR")" "$OUTPUT_DIR"

if [ ! -d "$WORK_DIR/.git" ]; then
  git clone "$UPSTREAM_URL" "$WORK_DIR"
fi

git -C "$WORK_DIR" fetch --tags origin
if git -C "$WORK_DIR" rev-parse --verify --quiet "origin/$UPSTREAM_REF^{commit}" >/dev/null; then
  git -C "$WORK_DIR" checkout -f "origin/$UPSTREAM_REF"
else
  git -C "$WORK_DIR" checkout -f "$UPSTREAM_REF"
fi

rm -rf "$WORK_DIR/dist"

printf 'Building %s from %s at %s\n' "$PACKAGE_NAME" "$UPSTREAM_URL" "$(git -C "$WORK_DIR" rev-parse --short HEAD)"

(
  cd "$WORK_DIR"
  MAX_BUILD_THREADS="$MAX_BUILD_THREADS" make build-app-fresh
  MAX_BUILD_THREADS="$MAX_BUILD_THREADS" \
    PACKAGE_NAME="$PACKAGE_NAME" \
    PACKAGE_DISPLAY_NAME="$PACKAGE_DISPLAY_NAME" \
    PACKAGE_COMMENT="$PACKAGE_COMMENT" \
    PACKAGE_WITH_UPDATER="$PACKAGE_WITH_UPDATER" \
    make pacman
)

latest_pkg="$(find "$WORK_DIR/dist" -maxdepth 1 -type f -name "$PACKAGE_NAME-[0-9]*.pkg.tar.*" | sort -V | tail -n 1)"

if [ -z "$latest_pkg" ]; then
  printf 'No generated package found under %s/dist\n' "$WORK_DIR" >&2
  exit 1
fi

dest="$OUTPUT_DIR/$(basename "$latest_pkg")"
cp "$latest_pkg" "$dest"
ln -sfn "$(basename "$dest")" "$OUTPUT_DIR/$PACKAGE_NAME-latest.pkg.tar.zst"
cp "$dest" "$OUTPUT_DIR/$PACKAGE_NAME-x86_64.pkg.tar.zst"
sha256sum "$dest" | tee "$dest.sha256"
sha256sum "$OUTPUT_DIR/$PACKAGE_NAME-x86_64.pkg.tar.zst" | tee "$OUTPUT_DIR/$PACKAGE_NAME-x86_64.pkg.tar.zst.sha256"

printf '\nBuilt package:\n  %s\n' "$dest"
printf 'Latest symlink:\n  %s\n' "$OUTPUT_DIR/$PACKAGE_NAME-latest.pkg.tar.zst"
printf 'Stable prebuilt asset:\n  %s\n' "$OUTPUT_DIR/$PACKAGE_NAME-x86_64.pkg.tar.zst"
