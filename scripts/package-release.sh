#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION_FILE="$ROOT_DIR/VERSION"
OUTPUT_DIR="${2:-$ROOT_DIR/dist}"
VERSION_INPUT="${1:-}"

usage() {
  cat <<EOF
Usage:
  ./scripts/package-release.sh [version] [output-dir]

Examples:
  ./scripts/package-release.sh
  ./scripts/package-release.sh 0.2.0
  ./scripts/package-release.sh 0.2.0 ./dist
EOF
}

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

read_version() {
  if [ -n "$VERSION_INPUT" ]; then
    printf '%s\n' "$VERSION_INPUT"
    return 0
  fi

  if [ ! -f "$VERSION_FILE" ]; then
    die "Missing VERSION file at $VERSION_FILE"
  fi

  tr -d '\n' < "$VERSION_FILE"
}

main() {
  local version package_name temp_dir package_dir archive_path stable_archive_path checksum

  if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    exit 0
  fi

  version="$(read_version)"
  package_name="colorbash-v$version"
  temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/colorbash-release.XXXXXX")"
  package_dir="$temp_dir/$package_name"
  archive_path="$OUTPUT_DIR/$package_name.tar.gz"
  stable_archive_path="$OUTPUT_DIR/colorbash.tar.gz"

  mkdir -p "$OUTPUT_DIR" "$package_dir" "$package_dir/scripts" "$package_dir/bucket"

  install -m 0755 "$ROOT_DIR/colorbash" "$package_dir/colorbash"
  install -m 0755 "$ROOT_DIR/cb" "$package_dir/cb"
  install -m 0644 "$ROOT_DIR/colorbash-init.sh" "$package_dir/colorbash-init.sh"
  install -m 0755 "$ROOT_DIR/install.sh" "$package_dir/install.sh"
  install -m 0755 "$ROOT_DIR/uninstall.sh" "$package_dir/uninstall.sh"
  install -m 0755 "$ROOT_DIR/bootstrap.ps1" "$package_dir/bootstrap.ps1"
  install -m 0755 "$ROOT_DIR/scripts/generate-homebrew-formula.sh" "$package_dir/scripts/generate-homebrew-formula.sh"
  install -m 0755 "$ROOT_DIR/scripts/generate-scoop-manifest.sh" "$package_dir/scripts/generate-scoop-manifest.sh"
  install -m 0644 "$ROOT_DIR/bucket/colorbash.json" "$package_dir/bucket/colorbash.json"
  install -m 0644 "$ROOT_DIR/README.md" "$package_dir/README.md"
  install -m 0644 "$ROOT_DIR/LICENSE" "$package_dir/LICENSE"
  install -m 0644 "$ROOT_DIR/LICENSING.md" "$package_dir/LICENSING.md"
  install -m 0644 "$ROOT_DIR/VERSION" "$package_dir/VERSION"

  # COPYFILE_DISABLE=1 stops macOS bsdtar from embedding ._* AppleDouble files.
  COPYFILE_DISABLE=1 tar -C "$temp_dir" -czf "$archive_path" "$package_name"
  cp "$archive_path" "$stable_archive_path"
  rm -rf "$temp_dir"

  if command -v shasum >/dev/null 2>&1; then
    checksum="$(shasum -a 256 "$archive_path" | awk '{print $1}')"
  elif command -v sha256sum >/dev/null 2>&1; then
    checksum="$(sha256sum "$archive_path" | awk '{print $1}')"
  else
    die "Need shasum or sha256sum to compute the release checksum."
  fi

  printf 'Created release archives:\n'
  printf '  %s\n' "$archive_path"
  printf '  %s\n' "$stable_archive_path"
  printf 'SHA256:\n'
  printf '  %s\n' "$checksum"
}

main "$@"
