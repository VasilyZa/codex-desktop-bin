#!/usr/bin/env bash
set -Eeuo pipefail

REPOSITORY_NAME="juckz"
REPOSITORY_URL="${JUCKZ_REPOSITORY_URL:-https://github.com/JuckZ/codex-desktop-bin/releases/latest/download}"
PACMAN_CONFIG="${PACMAN_CONFIG:-/etc/pacman.conf}"
REPOSITORY_CONFIG="${REPOSITORY_CONFIG:-/etc/pacman.d/juckz.conf}"
INCLUDE_LINE="Include = $REPOSITORY_CONFIG"

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  printf 'Run this setup script as root, for example: sudo bash %s\n' "$0" >&2
  exit 1
fi

command -v pacman >/dev/null 2>&1 || {
  printf 'This repository supports pacman-based Arch Linux systems only.\n' >&2
  exit 1
}

[ -f "$PACMAN_CONFIG" ] || {
  printf 'Missing pacman configuration: %s\n' "$PACMAN_CONFIG" >&2
  exit 1
}

install -d -m 0755 "$(dirname "$REPOSITORY_CONFIG")"
config_tmp="$(mktemp "${REPOSITORY_CONFIG}.XXXXXX")"
cleanup() {
  rm -f -- "$config_tmp"
}
trap cleanup EXIT

printf '%s\n' \
  "[$REPOSITORY_NAME]" \
  'SigLevel = Never' \
  "Server = $REPOSITORY_URL" > "$config_tmp"
chmod 0644 "$config_tmp"
mv -f -- "$config_tmp" "$REPOSITORY_CONFIG"

if ! grep -Fqx "$INCLUDE_LINE" "$PACMAN_CONFIG"; then
  if [ ! -e "${PACMAN_CONFIG}.juckz.bak" ]; then
    cp -a -- "$PACMAN_CONFIG" "${PACMAN_CONFIG}.juckz.bak"
  fi
  printf '\n# JuckZ codex-desktop repository\n%s\n' "$INCLUDE_LINE" >> "$PACMAN_CONFIG"
fi

printf 'Configured [%s] from %s\n' "$REPOSITORY_NAME" "$REPOSITORY_URL"
printf 'Install or update safely with:\n  sudo pacman -Syu %s/codex-desktop\n' "$REPOSITORY_NAME"
