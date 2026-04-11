#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_FILE="${5:-$ROOT_DIR/Formula/colorbash.rb}"

usage() {
  cat <<EOF
Usage:
  ./scripts/generate-homebrew-formula.sh <github-owner> <repo> <version> <sha256> [output-file]

Example:
  ./scripts/generate-homebrew-formula.sh alexprof colorBash 0.1.0 <sha256>
EOF
}

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

main() {
  local owner repo version sha256

  if [ "$#" -lt 4 ] || [ "$#" -gt 5 ]; then
    usage
    exit 1
  fi

  owner="$1"
  repo="$2"
  version="$3"
  sha256="$4"

  mkdir -p "$(dirname "$OUTPUT_FILE")"

  cat > "$OUTPUT_FILE" <<EOF
class Colorbash < Formula
  desc "Color one exact folder name differently in terminal ls output"
  homepage "https://github.com/$owner/$repo"
  url "https://github.com/$owner/$repo/releases/download/v$version/colorbash-v$version.tar.gz"
  sha256 "$sha256"
  license "AGPL-3.0-only"

  def install
    bin.install "colorbash", "cb"
    pkgshare.install "README.md", "LICENSE", "LICENSING.md", "VERSION", "colorbash-init.sh"
  end

  def caveats
    <<~EOS
      Add colorbash to your shell startup:
        eval "\$(colorbash init)"
    EOS
  end

  test do
    ENV["COLORBASH_CONFIG_DIR"] = testpath/".config/colorbash"
    system bin/"colorbash", "test_case", "red"
    output = shell_output("#{bin}/colorbash list")
    assert_match "test_case", output
    assert_match "red", output
  end
end
EOF

  printf 'Wrote Homebrew formula to %s\n' "$OUTPUT_FILE"
}

main "$@"
