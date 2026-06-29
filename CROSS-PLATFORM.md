# Installing colorbash on macOS, Linux, and Windows

colorbash is a **bash** tool. It works anywhere there's a bash (or zsh) shell
with a normal `ls`. That means macOS and Linux run it natively, and Windows runs
it through a bash environment (Git Bash or WSL). It does **not** run in native
PowerShell or `cmd.exe` — those don't have bash or the `ls` it wraps.

The terminal one-liners below are the easiest path on each OS.

---

## macOS

Already supported. Either Homebrew or the curl installer:

```bash
brew tap amm22-lab/colorbash
brew install colorbash
echo 'eval "$(colorbash init)"' >> ~/.zshrc
source ~/.zshrc
```

Or in one command:

```bash
brew install amm22-lab/colorbash/colorbash
echo 'eval "$(colorbash init)"' >> ~/.zshrc
source ~/.zshrc
```

```bash
curl -fsSL https://raw.githubusercontent.com/amm22-lab/colorBash/main/bootstrap.sh | bash -s -- --configure-shell
```

---

## Linux

The exact same code runs on Linux unchanged — the script already falls back from
the BSD `ls -G` flag to GNU `ls --color=auto`. You have three options.

### 1. One-line curl installer (easiest)

```bash
curl -fsSL https://raw.githubusercontent.com/amm22-lab/colorBash/main/bootstrap.sh | bash -s -- --configure-shell
```

This installs `colorbash` and `cb` into `~/.local/bin` and adds the managed
startup block to `~/.bashrc` (or `~/.bash_profile`/`~/.profile`).

### 2. Homebrew on Linux

Homebrew runs on Linux too, and the **same formula** works — no separate Linux
formula needed:

```bash
brew tap amm22-lab/colorbash
brew install colorbash
echo 'eval "$(colorbash init)"' >> ~/.bashrc
source ~/.bashrc
```

### 3. From a clone or downloaded archive

```bash
chmod +x install.sh
./install.sh --configure-shell
```

To uninstall on Linux: `./uninstall.sh` (add `--purge-config` to also remove
`~/.config/colorbash`).

---

## Windows

colorbash needs a bash shell, so on Windows you run it inside **Git Bash**
(small, recommended) or **WSL** (full Linux). Pick whichever you prefer.

### Option A — Scoop (the `brew install` equivalent for Windows)

[Scoop](https://scoop.sh) is a terminal package manager, no admin rights needed.
Once the bucket is published:

```powershell
# one-time: install Scoop if you don't have it
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
irm get.scoop.sh | iex

# add the colorbash bucket, then install
scoop bucket add colorbash https://github.com/amm22-lab/colorBash
scoop install colorbash
```

This pulls in Git (which provides Git Bash) automatically and wires up your
`~/.bashrc`. After it finishes, open **Git Bash** and use `cb` and `ls` as on
macOS/Linux.

### Option B — PowerShell one-liner (no Scoop)

The direct analog of the curl installer. Run in PowerShell:

```powershell
irm https://raw.githubusercontent.com/amm22-lab/colorBash/main/bootstrap.ps1 | iex
```

It finds Git Bash (or WSL), downloads the latest release, and runs the bundled
`install.sh` for you. If no bash environment is found it tells you exactly how to
get one:

```powershell
winget install --id Git.Git -e   # Git Bash (recommended)
# or
wsl --install                    # full Linux
```

Flags:

```powershell
# force a specific target
irm https://raw.githubusercontent.com/amm22-lab/colorBash/main/bootstrap.ps1 -OutFile cb.ps1
.\cb.ps1 -Target wsl
.\cb.ps1 -Target gitbash
.\cb.ps1 -NoConfigureShell   # install but don't touch ~/.bashrc
```

### Option C — WSL (treat it as Linux)

If you already use WSL, just open your distro and follow the **Linux** steps
above. Everything works identically there.

### Using it on Windows

After installing, in **Git Bash**:

```bash
cb test_case red
cb assets orange
ls
```

> Note: run these in Git Bash, not PowerShell/cmd. PowerShell's `ls` is
> `Get-ChildItem`, a different command that colorbash doesn't wrap.

---

## What about a native PowerShell version?

Making `cb`/`ls` color exact names inside **native PowerShell** (no Git Bash)
would be a separate rewrite: PowerShell uses `Get-ChildItem` with a formatting
engine instead of a POSIX `ls`, so the wrapping logic, ANSI handling, and rule
storage would need to be reimplemented in PowerShell. It's doable but it's a new
implementation, not a packaging change. The Git Bash / WSL route reuses your
existing, tested bash code as-is, which is why it's the recommended path today.

---

## For maintainers: cutting a release that supports all three

1. Bump `VERSION`.
2. Build the archives (works on macOS or Linux now):
   ```bash
   ./scripts/package-release.sh
   ```
   Copy the printed **SHA256**.
3. Regenerate both package definitions with that checksum:
   ```bash
   ./scripts/generate-homebrew-formula.sh amm22-lab colorBash <version> <sha256>
   ./scripts/generate-scoop-manifest.sh   amm22-lab colorBash <version> <sha256>
   ```
4. Create the GitHub Release and upload both `colorbash-v<version>.tar.gz` and
   `colorbash.tar.gz`.
5. Publish `Formula/colorbash.rb` to your Homebrew tap and `bucket/colorbash.json`
   in this repo (the `bucket/` directory is what Scoop reads when users add it).

The curl and PowerShell bootstrap installers always pull the **latest** release,
so they need no per-release edits.
