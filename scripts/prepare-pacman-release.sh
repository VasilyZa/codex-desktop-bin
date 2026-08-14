#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGE_PATH="${1:-$REPO_ROOT/dist/codex-desktop-latest.pkg.tar.zst}"
RELEASE_DIR="${RELEASE_DIR:-$REPO_ROOT/release}"
PACKAGING_COMMIT="${PACKAGING_COMMIT:-$(git -C "$REPO_ROOT" rev-parse HEAD)}"
PACKAGING_REPOSITORY="${PACKAGING_REPOSITORY:-JuckZ/codex-desktop-bin}"
UPSTREAM_REF="${UPSTREAM_REF:-main}"
WORKFLOW_RUN_URL="${WORKFLOW_RUN_URL:-}"

for command in bsdtar node pacman sha256sum; do
  command -v "$command" >/dev/null 2>&1 || {
    printf 'Missing required command: %s\n' "$command" >&2
    exit 1
  }
done

PACKAGE_PATH="$(readlink -f "$PACKAGE_PATH")"
[ -f "$PACKAGE_PATH" ] || {
  printf 'Package not found: %s\n' "$PACKAGE_PATH" >&2
  exit 1
}

package_name="$(LC_ALL=C pacman -Qp "$PACKAGE_PATH" | awk 'NR == 1 { print $1 }')"
package_version="$(LC_ALL=C pacman -Qp "$PACKAGE_PATH" | awk 'NR == 1 { print $2 }')"
[ "$package_name" = codex-desktop ] || {
  printf 'Refusing unexpected package: %s\n' "$package_name" >&2
  exit 1
}

package_file="$(basename "$PACKAGE_PATH")"
package_sha256="$(sha256sum "$PACKAGE_PATH" | awk '{ print $1 }')"
package_architecture="$(bsdtar -xOf "$PACKAGE_PATH" .PKGINFO | awk '$1 == "arch" { print $3; exit }')"
build_info_path=""
while IFS= read -r archive_path; do
  if [[ "$archive_path" =~ (^|/)\.codex-linux/build-info\.json$ ]]; then
    build_info_path="$archive_path"
    break
  fi
done < <(bsdtar -tf "$PACKAGE_PATH")

[ -n "$build_info_path" ] || {
  printf 'Package does not contain .codex-linux/build-info.json\n' >&2
  exit 1
}

mkdir -p "$RELEASE_DIR"
cp "$PACKAGE_PATH" "$RELEASE_DIR/$package_file"
(
  cd "$RELEASE_DIR"
  sha256sum "$package_file" > "$package_file.sha256"
)
bsdtar -xOf "$PACKAGE_PATH" "$build_info_path" > "$RELEASE_DIR/build-info.json"

PACKAGE_ARCHITECTURE="$package_architecture" \
PACKAGE_FILE="$package_file" \
PACKAGE_SHA256="$package_sha256" \
PACKAGE_VERSION="$package_version" \
PACKAGING_COMMIT="$PACKAGING_COMMIT" \
PACKAGING_REPOSITORY="$PACKAGING_REPOSITORY" \
UPSTREAM_REF="$UPSTREAM_REF" \
WORKFLOW_RUN_URL="$WORKFLOW_RUN_URL" \
node <<'NODE'
const crypto = require("node:crypto");
const fs = require("node:fs");
const path = require("node:path");

const info = JSON.parse(
  fs.readFileSync(path.join(process.env.RELEASE_DIR, "build-info.json"), "utf8"),
);
const identity = {
  architecture: process.env.PACKAGE_ARCHITECTURE,
  packagingCommit: process.env.PACKAGING_COMMIT,
  upstreamPayloadSha256: info.upstreamLinuxPackage.sha256,
  upstreamSourceCommit: info.source.commit,
};
const candidateKey = crypto
  .createHash("sha256")
  .update(JSON.stringify(identity))
  .digest("hex");
const metadata = {
  schemaVersion: 1,
  candidateKey,
  package: {
    name: "codex-desktop",
    version: process.env.PACKAGE_VERSION,
    architecture: process.env.PACKAGE_ARCHITECTURE,
    fileName: process.env.PACKAGE_FILE,
    sha256: process.env.PACKAGE_SHA256,
  },
  upstreamLinuxPackage: info.upstreamLinuxPackage,
  upstreamSource: info.source,
  packaging: {
    repository: process.env.PACKAGING_REPOSITORY,
    commit: process.env.PACKAGING_COMMIT,
    workflowRun: process.env.WORKFLOW_RUN_URL || null,
    upstreamRef: process.env.UPSTREAM_REF,
  },
};
fs.writeFileSync(
  path.join(process.env.RELEASE_DIR, "release-metadata.json"),
  `${JSON.stringify(metadata, null, 2)}\n`,
);
NODE

(cd "$RELEASE_DIR" && sha256sum -c "$package_file.sha256")

candidate_key="$(node -p "require('$RELEASE_DIR/release-metadata.json').candidateKey")"
upstream_version="$(node -p "require('$RELEASE_DIR/build-info.json').upstreamLinuxPackage.version")"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
  {
    printf 'candidate_key=%s\n' "$candidate_key"
    printf 'package_file=%s\n' "$package_file"
    printf 'package_version=%s\n' "$package_version"
    printf 'upstream_version=%s\n' "$upstream_version"
  } >> "$GITHUB_OUTPUT"
fi

printf 'Prepared %s %s (%s) for release\n' \
  "$package_name" "$package_version" "$package_architecture"
printf 'Candidate identity: %s\n' "$candidate_key"
