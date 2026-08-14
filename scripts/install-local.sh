#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_PATH="${PACKAGE_PATH:-$REPO_ROOT/dist/codex-desktop-latest.pkg.tar.zst}"

command -v pacman >/dev/null 2>&1 || {
  printf 'This installer requires pacman (Arch/CachyOS).\n' >&2
  exit 1
}

if [ ! -f "$PACKAGE_PATH" ]; then
  printf 'Package not found: %s\nRun ./scripts/build-latest.sh first.\n' "$PACKAGE_PATH" >&2
  exit 1
fi

package_name="$(LC_ALL=C pacman -Qp "$PACKAGE_PATH" | awk 'NR == 1 { print $1 }')"
[ "$package_name" = "codex-desktop" ] || {
  printf 'Refusing unexpected package %s from %s\n' "$package_name" "$PACKAGE_PATH" >&2
  exit 1
}

if pgrep -f '/opt/(codex-desktop|codex-desktop-bin)/ChatGPT|/opt/codex-desktop/start.sh|/opt/codex-desktop-bin/start.sh' >/dev/null 2>&1; then
  printf 'ChatGPT/Codex Desktop is running. Fully quit it, then rerun this script.\n' >&2
  exit 1
fi

# The package declares replaces=codex-desktop-bin, so libalpm removes the old
# package and installs the new one in a single checked transaction.
pacman -Q codex-desktop-bin >/dev/null 2>&1 && \
  printf 'Replacing legacy codex-desktop-bin with codex-desktop. User data under ~/.codex is preserved.\n'
if pacman -Q codex-desktop-bin >/dev/null 2>&1; then
  sudo pacman -U --needed --noconfirm --ask=4 "$PACKAGE_PATH"
else
  sudo pacman -U --needed --noconfirm "$PACKAGE_PATH"
fi

printf '\nInstalled package:\n'
pacman -Qi codex-desktop | sed -n '1,24p'
