if [ -z "${COLORBASH_BIN:-}" ]; then
  printf '%s\n' "colorbash init error: COLORBASH_BIN is not set." >&2
  return 1 2>/dev/null || exit 1
fi

unalias cb cbls ls 2>/dev/null || true

cb() {
  "$COLORBASH_BIN" "$@"
}

cbls() {
  "$COLORBASH_BIN" ls "$@"
}

ls() {
  cbls "$@"
}
