#!/usr/bin/env bash

set -euo pipefail

OWNER="${COLORBASH_GITHUB_OWNER:-amm22-lab}"
REPO="${COLORBASH_GITHUB_REPO:-colorBash}"
ASSET_NAME="${COLORBASH_RELEASE_ASSET:-colorbash.tar.gz}"

usage() {
  cat <<EOF
Usage:
  ./bootstrap.sh [install.sh options]

Examples:
  ./bootstrap.sh --configure-shell
  ./bootstrap.sh --prefix "\$HOME/.local"
  curl -fsSL https://raw.githubusercontent.com/$OWNER/$REPO/main/bootstrap.sh | bash -s -- --configure-shell
EOF
}

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

find_package_dir() {
  find "$1" -mindepth 1 -maxdepth 1 -type d -name 'colorbash-v*' -print -quit
}

main() {
  local tmp_dir archive_path package_dir release_url script_dir local_install

  if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    exit 0
  fi

  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local_install="$script_dir/install.sh"
  if [ -f "$local_install" ] && [ -f "$script_dir/colorbash" ]; then
    exec "$local_install" "$@"
  fi

  tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/colorbash-bootstrap.XXXXXX")"
  trap 'rm -rf "$tmp_dir"' EXIT

  archive_path="$tmp_dir/$ASSET_NAME"
  release_url="https://github.com/$OWNER/$REPO/releases/latest/download/$ASSET_NAME"

  printf 'Downloading latest colorbash release...\n'
  curl -fsSL "$release_url" -o "$archive_path" || die "Failed to download $release_url"

  tar -xzf "$archive_path" -C "$tmp_dir"
  package_dir="$(find_package_dir "$tmp_dir")"
  [ -n "$package_dir" ] || die "Could not find the extracted colorbash package directory"

  "$package_dir/install.sh" "$@"
}

main "$@"
