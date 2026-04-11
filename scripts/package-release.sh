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
  local version package_name temp_dir package_dir archive_path checksum

  if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    exit 0
  fi

  version="$(read_version)"
  package_name="colorbash-v$version"
  temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/colorbash-release.XXXXXX")"
  package_dir="$temp_dir/$package_name"
  archive_path="$OUTPUT_DIR/$package_name.tar.gz"

  mkdir -p "$OUTPUT_DIR" "$package_dir" "$package_dir/scripts"

  install -m 0755 "$ROOT_DIR/colorbash" "$package_dir/colorbash"
  install -m 0755 "$ROOT_DIR/cb" "$package_dir/cb"
  install -m 0755 "$ROOT_DIR/install.sh" "$package_dir/install.sh"
  install -m 0755 "$ROOT_DIR/uninstall.sh" "$package_dir/uninstall.sh"
  install -m 0755 "$ROOT_DIR/scripts/generate-homebrew-formula.sh" "$package_dir/scripts/generate-homebrew-formula.sh"
  install -m 0644 "$ROOT_DIR/README.md" "$package_dir/README.md"
  install -m 0644 "$ROOT_DIR/LICENSE" "$package_dir/LICENSE"
  install -m 0644 "$ROOT_DIR/LICENSING.md" "$package_dir/LICENSING.md"
  install -m 0644 "$ROOT_DIR/VERSION" "$package_dir/VERSION"

  tar -C "$temp_dir" -czf "$archive_path" "$package_name"
  rm -rf "$temp_dir"

  checksum="$(shasum -a 256 "$archive_path" | awk '{print $1}')"

  printf 'Created release archive:\n'
  printf '  %s\n' "$archive_path"
  printf 'SHA256:\n'
  printf '  %s\n' "$checksum"
}

main "$@"
