#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_FILE="${5:-$ROOT_DIR/bucket/colorbash.json}"

usage() {
  cat <<EOF
Usage:
  ./scripts/generate-scoop-manifest.sh <github-owner> <repo> <version> <sha256> [output-file]

Example:
  ./scripts/generate-scoop-manifest.sh amm22-lab colorBash 0.1.3 <sha256>
EOF
}

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

main() {
  local owner repo version sha256 tmp

  if [ "$#" -lt 4 ] || [ "$#" -gt 5 ]; then
    usage
    exit 1
  fi

  owner="$1"
  repo="$2"
  version="$3"
  sha256="$4"

  mkdir -p "$(dirname "$OUTPUT_FILE")"
  tmp="$(mktemp "${TMPDIR:-/tmp}/colorbash-scoop.XXXXXX")"

  # Quoted heredoc: NOTHING is expanded, so all $ and \ in the PowerShell /
  # bash payload survive verbatim. Concrete values use @@PLACEHOLDER@@ markers.
  cat > "$tmp" <<'TEMPLATE'
{
    "version": "@@VERSION@@",
    "description": "Color exact file and folder names differently in terminal ls output (runs in Git Bash)",
    "homepage": "https://github.com/@@OWNER@@/@@REPO@@",
    "license": "AGPL-3.0-only",
    "notes": [
        "colorbash is a bash tool and runs inside Git Bash (installed via the 'git' dependency).",
        "Open Git Bash, then add colorbash to your shell startup if it isn't already:",
        "    echo 'eval \"$(colorbash init)\"' >> ~/.bashrc && source ~/.bashrc",
        "Then try:  cb test_case red   and   ls",
        "It does NOT run in PowerShell or cmd.exe - use Git Bash."
    ],
    "depends": [
        "git"
    ],
    "url": "https://github.com/@@OWNER@@/@@REPO@@/releases/download/v@@VERSION@@/colorbash-v@@VERSION@@.tar.gz",
    "hash": "@@SHA256@@",
    "extract_dir": "colorbash-v@@VERSION@@",
    "env_add_path": ".",
    "post_install": [
        "$bashrc = Join-Path $env:USERPROFILE '.bashrc'",
        "$start = '# >>> colorbash >>>'",
        "$alreadyThere = (Test-Path $bashrc) -and (Select-String -Path $bashrc -Pattern ([regex]::Escape($start)) -Quiet)",
        "if (-not $alreadyThere) {",
        "    $appPath = (Resolve-Path $dir).Path",
        "    $unixPath = '/' + ($appPath -replace ':','' -replace '\\\\','/')",
        "    $block = @()",
        "    $block += ''",
        "    $block += $start",
        "    $block += 'export PATH=\"' + $unixPath + ':$PATH\"'",
        "    $block += 'eval \"$(colorbash init)\"'",
        "    $block += '# <<< colorbash <<<'",
        "    Add-Content -Path $bashrc -Value $block -Encoding utf8",
        "    Write-Host 'Added a colorbash block to your Git Bash ~/.bashrc.' -ForegroundColor Green",
        "    Write-Host 'Open Git Bash (or run: source ~/.bashrc) to start using cb and ls.' -ForegroundColor Yellow",
        "} else {",
        "    Write-Host 'colorbash block already present in ~/.bashrc.' -ForegroundColor Green",
        "}"
    ],
    "pre_uninstall": [
        "$bashrc = Join-Path $env:USERPROFILE '.bashrc'",
        "if (Test-Path $bashrc) {",
        "    $lines = Get-Content $bashrc",
        "    $out = @(); $skip = $false",
        "    foreach ($l in $lines) {",
        "        if ($l -eq '# >>> colorbash >>>') { $skip = $true; continue }",
        "        if ($l -eq '# <<< colorbash <<<') { $skip = $false; continue }",
        "        if (-not $skip) { $out += $l }",
        "    }",
        "    Set-Content -Path $bashrc -Value $out -Encoding utf8",
        "    Write-Host 'Removed the colorbash block from ~/.bashrc.' -ForegroundColor Green",
        "}"
    ],
    "checkver": {
        "github": "https://github.com/@@OWNER@@/@@REPO@@"
    },
    "autoupdate": {
        "url": "https://github.com/@@OWNER@@/@@REPO@@/releases/download/v$version/colorbash-v$version.tar.gz",
        "extract_dir": "colorbash-v$version"
    }
}
TEMPLATE

  # Substitute only the four concrete fields. Scoop's own $version (autoupdate)
  # is left untouched on purpose.
  sed -e "s|@@OWNER@@|$owner|g" \
      -e "s|@@REPO@@|$repo|g" \
      -e "s|@@VERSION@@|$version|g" \
      -e "s|@@SHA256@@|$sha256|g" \
      "$tmp" > "$OUTPUT_FILE"

  rm -f "$tmp"
  printf 'Wrote Scoop manifest to %s\n' "$OUTPUT_FILE"
}

main "$@"
