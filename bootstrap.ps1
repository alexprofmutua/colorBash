#Requires -Version 5.1
<#
.SYNOPSIS
  One-line Windows installer for colorbash.

.DESCRIPTION
  colorbash is a bash tool, so on Windows it runs inside a bash environment.
  This installer finds Git Bash (or WSL), downloads the latest colorbash
  release, and hands off to the bundled install.sh, giving the exact same
  result as the macOS/Linux installer.

  Quick start (PowerShell):
    irm https://raw.githubusercontent.com/amm22-lab/colorBash/main/bootstrap.ps1 | iex

  Or download first, then run:
    irm https://raw.githubusercontent.com/amm22-lab/colorBash/main/bootstrap.ps1 -OutFile colorbash-bootstrap.ps1
    .\colorbash-bootstrap.ps1

.PARAMETER Target
  Where to install: 'gitbash' (default), 'wsl', or 'auto' (prefer Git Bash,
  fall back to WSL).

.PARAMETER NoConfigureShell
  Skip adding the managed colorbash block to your shell rc file.
#>

[CmdletBinding()]
param(
    [ValidateSet('auto', 'gitbash', 'wsl')]
    [string]$Target = 'auto',
    [switch]$NoConfigureShell
)

$ErrorActionPreference = 'Stop'

$Owner       = if ($env:COLORBASH_GITHUB_OWNER) { $env:COLORBASH_GITHUB_OWNER } else { 'amm22-lab' }
$Repo        = if ($env:COLORBASH_GITHUB_REPO)  { $env:COLORBASH_GITHUB_REPO }  else { 'colorBash' }
$AssetName   = if ($env:COLORBASH_RELEASE_ASSET) { $env:COLORBASH_RELEASE_ASSET } else { 'colorbash.tar.gz' }
$ReleaseUrl  = "https://github.com/$Owner/$Repo/releases/latest/download/$AssetName"

function Write-Step { param([string]$Msg) Write-Host "==> $Msg" -ForegroundColor Cyan }
function Write-Ok   { param([string]$Msg) Write-Host "    $Msg" -ForegroundColor Green }
function Die        { param([string]$Msg) Write-Host "error: $Msg" -ForegroundColor Red; exit 1 }

# --- Locate a bash environment -------------------------------------------------

function Find-GitBash {
    # 1) bash.exe already on PATH (but skip the WSL stub at System32\bash.exe)
    $cmd = Get-Command bash.exe -ErrorAction SilentlyContinue
    if ($cmd) {
        $p = $cmd.Source
        if ($p -and ($p -notlike "*\System32\bash.exe") -and ($p -notlike "*\WindowsApps\*")) {
            return $p
        }
    }
    # 2) Derive from git.exe location: <git>\cmd\git.exe -> <git>\bin\bash.exe
    $git = Get-Command git.exe -ErrorAction SilentlyContinue
    if ($git) {
        $root = Split-Path (Split-Path $git.Source -Parent) -Parent
        $candidate = Join-Path $root 'bin\bash.exe'
        if (Test-Path $candidate) { return $candidate }
    }
    # 3) Common install locations
    foreach ($c in @(
        "$env:ProgramFiles\Git\bin\bash.exe",
        "${env:ProgramFiles(x86)}\Git\bin\bash.exe",
        "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe"
    )) {
        if ($c -and (Test-Path $c)) { return $c }
    }
    return $null
}

function Test-Wsl {
    $wsl = Get-Command wsl.exe -ErrorAction SilentlyContinue
    if (-not $wsl) { return $false }
    try { wsl.exe -e true 2>$null; return ($LASTEXITCODE -eq 0) } catch { return $false }
}

# --- Acquire the package (local checkout or GitHub release) --------------------

function Get-PackageDir {
    param([string]$WorkDir)

    # If this script sits next to an install.sh, install from here (local zip/clone case).
    $localInstall = Join-Path $PSScriptRoot 'install.sh'
    if ($PSScriptRoot -and (Test-Path $localInstall)) {
        Write-Ok "Using local copy at $PSScriptRoot"
        return $PSScriptRoot
    }

    Write-Step "Downloading latest colorbash release"
    $archive = Join-Path $WorkDir $AssetName
    try {
        Invoke-WebRequest -Uri $ReleaseUrl -OutFile $archive -UseBasicParsing
    } catch {
        Die "Failed to download $ReleaseUrl`n$($_.Exception.Message)"
    }

    Write-Step "Extracting"
    # tar ships with Windows 10 1803+ and handles .tar.gz
    & tar.exe -xzf $archive -C $WorkDir
    if ($LASTEXITCODE -ne 0) { Die "tar failed to extract $archive" }

    $pkg = Get-ChildItem -Path $WorkDir -Directory |
           Where-Object { $_.Name -like 'colorbash-v*' } |
           Select-Object -First 1
    if (-not $pkg) { Die "Could not find extracted colorbash package directory" }
    return $pkg.FullName
}

# --- Install paths -------------------------------------------------------------

function Install-ViaGitBash {
    param([string]$BashExe)

    $work = Join-Path $env:TEMP ("colorbash-bootstrap-" + [System.Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $work -Force | Out-Null
    try {
        $pkgDir = Get-PackageDir -WorkDir $work

        # Convert the Windows path to a Git Bash path with cygpath inside bash itself.
        $configureFlag = if ($NoConfigureShell) { "" } else { "--configure-shell" }
        Write-Step "Running install.sh in Git Bash"

        # Run install.sh from its own directory; cd via cygpath so spaces/drive letters are safe.
        $bashCmd = 'dir="$(cygpath -u "$COLORBASH_PKG_WIN")"; cd "$dir" && chmod +x install.sh && ./install.sh ' + $configureFlag
        $env:COLORBASH_PKG_WIN = $pkgDir
        & $BashExe -lc $bashCmd
        $code = $LASTEXITCODE
        Remove-Item Env:\COLORBASH_PKG_WIN -ErrorAction SilentlyContinue
        if ($code -ne 0) { Die "install.sh exited with code $code" }

        Write-Host ""
        Write-Ok "colorbash installed for Git Bash."
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "  1. Close this window and open Git Bash."
        if ($NoConfigureShell) {
            Write-Host "  2. Add to ~/.bashrc:  eval " -NoNewline
            Write-Host '"$(colorbash init)"'
        } else {
            Write-Host "  2. Run:  source ~/.bashrc   (or just open a new Git Bash window)"
        }
        Write-Host "  3. Try it:  cb test_case red   then   ls"
    }
    finally {
        Remove-Item -Path $work -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Install-ViaWsl {
    Write-Step "Installing inside WSL (Linux)"
    $configureFlag = if ($NoConfigureShell) { "" } else { "--configure-shell" }
    # Inside WSL this is just the normal Linux curl-pipe install.
    $inner = "curl -fsSL https://raw.githubusercontent.com/$Owner/$Repo/main/bootstrap.sh | bash -s -- $configureFlag"
    & wsl.exe -e bash -lc $inner
    if ($LASTEXITCODE -ne 0) { Die "WSL install failed" }
    Write-Ok "colorbash installed inside your default WSL distro."
    Write-Host "Open WSL, then: cb test_case red   then   ls"
}

# --- Main ----------------------------------------------------------------------

Write-Host ""
Write-Host "colorbash Windows installer" -ForegroundColor Magenta
Write-Host "colorbash is a bash tool; it runs inside Git Bash or WSL." -ForegroundColor DarkGray
Write-Host ""

$gitBash = Find-GitBash
$hasWsl  = Test-Wsl

switch ($Target) {
    'gitbash' {
        if (-not $gitBash) {
            Die @"
Git Bash was not found.
Install Git for Windows (it bundles Git Bash), then re-run this script:
    winget install --id Git.Git -e
Or use WSL instead:  .\bootstrap.ps1 -Target wsl
"@
        }
        Install-ViaGitBash -BashExe $gitBash
    }
    'wsl' {
        if (-not $hasWsl) { Die "WSL was not found. Enable it with:  wsl --install" }
        Install-ViaWsl
    }
    default {  # auto
        if ($gitBash) {
            Write-Ok "Found Git Bash: $gitBash"
            Install-ViaGitBash -BashExe $gitBash
        }
        elseif ($hasWsl) {
            Write-Ok "Git Bash not found; using WSL."
            Install-ViaWsl
        }
        else {
            Die @"
No bash environment found.

Pick one of these, then re-run this installer:

  - Git for Windows (recommended, smallest):
        winget install --id Git.Git -e

  - WSL (full Linux):
        wsl --install

After installing either, run again:
    irm https://raw.githubusercontent.com/$Owner/$Repo/main/bootstrap.ps1 | iex
"@
        }
    }
}
