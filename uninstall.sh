#!/usr/bin/env bash

set -euo pipefail

PREFIX="${COLORBASH_PREFIX:-$HOME/.local}"
SHELL_RC=""
PURGE_CONFIG=0
usage() {
  cat <<EOF
Usage:
  ./uninstall.sh [--prefix DIR] [--shell-rc FILE] [--purge-config]

Options:
  --prefix DIR      Remove files from DIR instead of \$HOME/.local
  --shell-rc FILE   Remove the managed colorbash block from a specific shell rc file
  --purge-config    Also remove ~/.config/colorbash
  -h, --help        Show this help message
EOF
}

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

resolve_default_shell_rc() {
  local shell_name
  shell_name="${SHELL##*/}"

  case "$shell_name" in
    zsh)
      printf '%s/.zshrc\n' "$HOME"
      ;;
    bash)
      if [ -f "$HOME/.bash_profile" ]; then
        printf '%s/.bash_profile\n' "$HOME"
      else
        printf '%s/.bashrc\n' "$HOME"
      fi
      ;;
    *)
      printf '%s/.profile\n' "$HOME"
      ;;
  esac
}

remove_shell_block() {
  local rc_file temp_file
  rc_file="$1"

  if [ ! -f "$rc_file" ]; then
    return 0
  fi

  temp_file="$(mktemp "${TMPDIR:-/tmp}/colorbash-uninstall.XXXXXX")"
  awk '
    BEGIN { skip = 0 }
    /^# >>> colorbash >>>$/ { skip = 1; next }
    /^# <<< colorbash <<<$/{ skip = 0; next }
    skip == 0 { print }
  ' "$rc_file" > "$temp_file"
  mv "$temp_file" "$rc_file"
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --prefix)
        [ "$#" -ge 2 ] || die "Missing value for --prefix"
        PREFIX="$2"
        shift 2
        ;;
      --shell-rc)
        [ "$#" -ge 2 ] || die "Missing value for --shell-rc"
        SHELL_RC="$2"
        shift 2
        ;;
      --purge-config)
        PURGE_CONFIG=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "Unknown option: $1"
        ;;
    esac
  done
}

main() {
  local bin_dir share_dir

  parse_args "$@"

  bin_dir="$PREFIX/bin"
  share_dir="$PREFIX/share/colorbash"

  rm -f "$bin_dir/colorbash" "$bin_dir/cb"
  rm -rf "$share_dir"

  if [ -z "$SHELL_RC" ]; then
    SHELL_RC="$(resolve_default_shell_rc)"
  fi
  remove_shell_block "$SHELL_RC"

  if [ "$PURGE_CONFIG" -eq 1 ]; then
    rm -rf "$HOME/.config/colorbash"
    printf 'Removed colorbash config from %s/.config/colorbash\n' "$HOME"
  fi

  printf 'Removed colorbash from %s\n' "$PREFIX"
  printf 'If your current shell already loaded colorbash, open a new terminal window.\n'
}

main "$@"
