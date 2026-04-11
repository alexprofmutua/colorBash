#!/usr/bin/env bash

set -euo pipefail

PREFIX="${COLORBASH_PREFIX:-$HOME/.local}"
CONFIGURE_SHELL=0
SHELL_RC=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR=""
SHARE_DIR=""

usage() {
  cat <<EOF
Usage:
  ./install.sh [--prefix DIR] [--configure-shell] [--shell-rc FILE]

Options:
  --prefix DIR        Install into DIR instead of \$HOME/.local
  --configure-shell   Append a managed colorbash block to your shell rc file
  --shell-rc FILE     Use a specific shell rc file with --configure-shell
  -h, --help          Show this help message

Examples:
  ./install.sh
  ./install.sh --configure-shell
  ./install.sh --prefix /usr/local
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

ensure_source_files() {
  local required_file
  for required_file in colorbash cb colorbash-init.sh README.md LICENSE LICENSING.md VERSION; do
    if [ ! -f "$SCRIPT_DIR/$required_file" ]; then
      die "Missing required file: $SCRIPT_DIR/$required_file"
    fi
  done
}

append_shell_block() {
  local rc_file block_start block_end
  rc_file="$1"
  block_start="# >>> colorbash >>>"
  block_end="# <<< colorbash <<<"

  mkdir -p "$(dirname "$rc_file")"
  touch "$rc_file"

  if grep -Fq "$block_start" "$rc_file"; then
    printf 'Shell config already contains a colorbash block in %s\n' "$rc_file"
    return 0
  fi

  {
    printf '\n%s\n' "$block_start"
    printf 'export PATH="%s/bin:$PATH"\n' "$PREFIX"
    printf 'eval "$(colorbash init)"\n'
    printf '%s\n' "$block_end"
  } >> "$rc_file"

  printf 'Updated shell config: %s\n' "$rc_file"
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --prefix)
        [ "$#" -ge 2 ] || die "Missing value for --prefix"
        PREFIX="$2"
        shift 2
        ;;
      --configure-shell)
        CONFIGURE_SHELL=1
        shift
        ;;
      --shell-rc)
        [ "$#" -ge 2 ] || die "Missing value for --shell-rc"
        SHELL_RC="$2"
        shift 2
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
  parse_args "$@"
  ensure_source_files

  BIN_DIR="$PREFIX/bin"
  SHARE_DIR="$PREFIX/share/colorbash"

  mkdir -p "$BIN_DIR" "$SHARE_DIR"

  install -m 0755 "$SCRIPT_DIR/colorbash" "$BIN_DIR/colorbash"
  install -m 0755 "$SCRIPT_DIR/cb" "$BIN_DIR/cb"
  install -m 0644 "$SCRIPT_DIR/colorbash-init.sh" "$SHARE_DIR/colorbash-init.sh"
  install -m 0644 "$SCRIPT_DIR/README.md" "$SHARE_DIR/README.md"
  install -m 0644 "$SCRIPT_DIR/LICENSE" "$SHARE_DIR/LICENSE"
  install -m 0644 "$SCRIPT_DIR/LICENSING.md" "$SHARE_DIR/LICENSING.md"
  install -m 0644 "$SCRIPT_DIR/VERSION" "$SHARE_DIR/VERSION"

  printf 'Installed colorbash to %s\n' "$BIN_DIR"

  if [ "$CONFIGURE_SHELL" -eq 1 ]; then
    if [ -z "$SHELL_RC" ]; then
      SHELL_RC="$(resolve_default_shell_rc)"
    fi
    append_shell_block "$SHELL_RC"
    printf 'Open a new terminal window, or run: source %s\n' "$SHELL_RC"
  else
    printf '\nNext steps:\n'
    printf '  1. Ensure %s is on your PATH\n' "$BIN_DIR"
    printf '  2. Add this to your shell config:\n'
    printf '       eval "$(colorbash init)"\n'
  fi
}

main "$@"
