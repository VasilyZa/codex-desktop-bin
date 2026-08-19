#!/usr/bin/env bash
set -Eeuo pipefail

REPOSITORY_NAME="juckz"
default_repository_url="https://github.com/JuckZ/arch-repo/releases/download/repository-\$arch"
REPOSITORY_URL="${JUCKZ_REPOSITORY_URL:-$default_repository_url}"
PACMAN_CONFIG="${PACMAN_CONFIG:-/etc/pacman.conf}"
REPOSITORY_CONFIG="${REPOSITORY_CONFIG:-/etc/pacman.d/juckz.conf}"
INCLUDE_LINE="Include = $REPOSITORY_CONFIG"
KEY_URL="https://raw.githubusercontent.com/JuckZ/arch-repo/main/keys/juckz-repo.asc"
KEY_FINGERPRINT="A36130B488E1E75604E60A9A92A815DA30F9FA93"

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  printf 'Run this setup script as root, for example: sudo bash %s\n' "$0" >&2
  exit 1
fi

for command in curl gpg pacman pacman-conf pacman-key; do
  command -v "$command" >/dev/null 2>&1 || {
    printf 'Missing required command: %s\n' "$command" >&2
    exit 1
  }
done

[ -f "$PACMAN_CONFIG" ] || {
  printf 'Missing pacman configuration: %s\n' "$PACMAN_CONFIG" >&2
  exit 1
}

key_file="$(mktemp)"
config_tmp=""
cleanup() {
  rm -f -- "$key_file"
  if [ -n "$config_tmp" ]; then
    rm -f -- "$config_tmp"
  fi
}
trap cleanup EXIT

curl --fail --location --silent --show-error --output "$key_file" "$KEY_URL"
downloaded_fingerprint="$(gpg --batch --show-keys --with-colons "$key_file" \
  | awk -F: '$1 == "fpr" { print $10; exit }')"
[ "$downloaded_fingerprint" = "$KEY_FINGERPRINT" ] || {
  printf 'Repository signing-key fingerprint mismatch\n' >&2
  exit 1
}
pacman-key --add "$key_file"
pacman-key --lsign-key "$KEY_FINGERPRINT"

write_repository_config() {
  install -d -m 0755 "$(dirname "$REPOSITORY_CONFIG")"
  config_tmp="$(mktemp "${REPOSITORY_CONFIG}.XXXXXX")"
  printf '%s\n' \
    "[$REPOSITORY_NAME]" \
    'SigLevel = Required DatabaseOptional' \
    "Server = $REPOSITORY_URL" > "$config_tmp"
  chmod 0644 "$config_tmp"
  mv -f -- "$config_tmp" "$REPOSITORY_CONFIG"
  config_tmp=""
}

if grep -Fqx "$INCLUDE_LINE" "$PACMAN_CONFIG"; then
  write_repository_config
elif pacman-conf --config "$PACMAN_CONFIG" --repo-list \
    | grep -Fqx "$REPOSITORY_NAME"; then
  configured_server="$(pacman-conf --config "$PACMAN_CONFIG" \
    --repo "$REPOSITORY_NAME" | awk -F ' = ' '$1 == "Server" { print $2; exit }')"
  case "$configured_server" in
    https://github.com/JuckZ/arch-repo/releases/download/repository-*) ;;
    *)
      printf '[%s] already exists with an unexpected server: %s\n' \
        "$REPOSITORY_NAME" "$configured_server" >&2
      exit 1
      ;;
  esac
  configured_siglevel="$(pacman-conf --config "$PACMAN_CONFIG" \
    --repo "$REPOSITORY_NAME" \
    | awk -F ' = ' '$1 == "SigLevel" { print $2; exit }')"
  case " $configured_siglevel " in
    *" PackageRequired "*) ;;
    *)
      printf '[%s] must require package signatures; found: %s\n' \
        "$REPOSITORY_NAME" "${configured_siglevel:-unset}" >&2
      printf 'Set: SigLevel = Required DatabaseOptional\n' >&2
      exit 1
      ;;
  esac
else
  write_repository_config
  if [ ! -e "${PACMAN_CONFIG}.juckz.bak" ]; then
    cp -a -- "$PACMAN_CONFIG" "${PACMAN_CONFIG}.juckz.bak"
  fi
  printf '\n# JuckZ signed package repository\n%s\n' "$INCLUDE_LINE" >> "$PACMAN_CONFIG"
fi

printf 'Configured signed [%s] repository from %s\n' \
  "$REPOSITORY_NAME" "$REPOSITORY_URL"
printf 'Install or update safely with:\n  sudo pacman -Syu %s/codex-desktop\n' \
  "$REPOSITORY_NAME"
