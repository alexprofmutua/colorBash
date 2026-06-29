# colorbash

`colorbash` lets you color one exact file or folder name differently in your terminal `ls` output.

macOS and Linux `ls` only colors by file type, not by exact name, so this project solves that by:

- saving exact file/folder-name color rules with `cb <name> <color>`
- saving a random color per visible file/folder in the current directory with `cb random`
- wrapping plain interactive `ls` so your chosen file or folder name gets its own color

## Preview

### Before

![Before colorbash](examples/before.svg)

### After

![After colorbash](examples/after.svg)

These images are simple mockups of the terminal output, so your exact font, spacing, and colors may vary a little depending on your shell theme.

## Install

colorbash runs natively on **macOS** and **Linux**, and on **Windows** through
Git Bash or WSL (it's a bash tool, so it doesn't run in native PowerShell/cmd).
Full per-OS details are in [CROSS-PLATFORM.md](CROSS-PLATFORM.md); the short
version is below.

### macOS / Linux — Homebrew

One-time tap, then install like any other formula:

```bash
brew tap amm22-lab/colorbash
brew install colorbash
echo 'eval "$(colorbash init)"' >> ~/.zshrc   # or ~/.bashrc on Linux
source ~/.zshrc
```

You can also install in one command without adding the tap first:

```bash
brew install amm22-lab/colorbash/colorbash
```

### macOS / Linux — one-line install without Homebrew

```bash
curl -fsSL https://raw.githubusercontent.com/amm22-lab/colorBash/main/bootstrap.sh | bash -s -- --configure-shell
```

If you prefer not to pipe straight into `bash`, download it first:

```bash
curl -fsSL -o colorbash-bootstrap.sh https://raw.githubusercontent.com/amm22-lab/colorBash/main/bootstrap.sh
bash colorbash-bootstrap.sh --configure-shell
```

### Windows — Scoop (the `brew install` equivalent)

```powershell
scoop bucket add colorbash https://github.com/amm22-lab/colorBash
scoop install colorbash
```

This pulls in Git Bash automatically and configures `~/.bashrc`. Then open
**Git Bash** to use `cb` and `ls`.

### Windows — PowerShell one-liner (no Scoop)

```powershell
irm https://raw.githubusercontent.com/amm22-lab/colorBash/main/bootstrap.ps1 | iex
```

Finds Git Bash or WSL, downloads the latest release, and runs the installer. If
no bash environment is present it tells you how to install one
(`winget install --id Git.Git -e` or `wsl --install`).

### Fastest local install

If someone downloads this project as a zip, tarball, or git clone, they can install it with:

```bash
chmod +x install.sh
./install.sh --configure-shell
```

That installs `colorbash` and `cb` into `~/.local/bin` by default and adds a managed shell block with:

```bash
eval "$(colorbash init)"
```

### Manual install

If you prefer to do it yourself:

```bash
chmod +x colorbash cb
export PATH="/path/to/colorBash:$PATH"
eval "$(colorbash init)"
```

### Uninstall

```bash
chmod +x uninstall.sh
./uninstall.sh
```

## Usage

Set a custom color for one folder name:

```bash
cb test_case red
```

Use one of the extra named colors:

```bash
cb assets orange
cb docs teal
cb screenshots pink
```

Use a hex color:

```bash
cb test_case '#ff7a00'
```

Use a 256-color code:

```bash
cb test_case 214
```

Show saved rules:

```bash
cb list
```

Assign random colors to the visible files and folders in the current directory:

```bash
cb random
```

Remove one rule:

```bash
cb remove test_case
```

Clear every saved rule:

```bash
cb clear
```

## Supported Colors

- Named colors: `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`, `white`
- Extra named colors: `orange`, `pink`, `teal`, `purple`, `violet`, `indigo`, `lime`, `gold`, `coral`, `turquoise`, `brown`, `navy`, `olive`, `maroon`, `silver`
- Bright colors: `bright-red`, `bright-blue`, `bright-cyan`, and similar
- 256-color palette values: `0` through `255`
- Hex values: `#RRGGBB`

## How It Works

After you add `eval "$(colorbash init)"` to your shell config:

- `cb` stores exact file/folder-name color rules in `~/.config/colorbash/rules.tsv`
- `cb random` stores directory-scoped random rules for the current folder only
- `ls` is wrapped for simple interactive use in the current directory
- unsupported `ls` modes fall back to your normal system `ls`

## Current Scope

The custom coloring is applied for interactive:

- `ls`
- `ls -a`
- `ls -A`
- `ls -1`

Other `ls` forms fall back to the native command so your normal workflow stays safe.

## Distribution

The easiest way to share `colorbash` is:

1. publish this repo on GitHub
2. create a release archive with `./scripts/package-release.sh`
3. upload both generated release files to a GitHub Release
4. tell users to either install with Homebrew or use the bootstrap installer

### Homebrew

Once you have a public GitHub repo and release tarball:

1. run `./scripts/package-release.sh`
2. copy the printed SHA256 value
3. generate a formula with:

```bash
./scripts/generate-homebrew-formula.sh <github-owner> <repo> <version> <sha256>
```

That writes [Formula/colorbash.rb](Formula/colorbash.rb), which you can place in your Homebrew tap repository.

For the full GitHub release and Homebrew tap workflow, see [PUBLISHING.md](PUBLISHING.md).

### Scoop (Windows)

After the release tarball is published, generate the Scoop manifest with the same
SHA256:

```bash
./scripts/generate-scoop-manifest.sh <github-owner> <repo> <version> <sha256>
```

That writes [bucket/colorbash.json](bucket/colorbash.json). This repository doubles
as a Scoop bucket, so users can install with:

```powershell
scoop bucket add colorbash https://github.com/amm22-lab/colorBash
scoop install colorbash
```

The manifest declares `git` as a dependency (which provides Git Bash) and wires
up `~/.bashrc` on install. See [CROSS-PLATFORM.md](CROSS-PLATFORM.md) for the
full Windows story, including the PowerShell one-line installer.

### No Homebrew

The bootstrap installer downloads the latest stable release asset from GitHub and runs the bundled installer:

```bash
curl -fsSL https://raw.githubusercontent.com/amm22-lab/colorBash/main/bootstrap.sh | bash -s -- --configure-shell
```

## License

This project is available under the GNU Affero General Public License v3.0 in [LICENSE](LICENSE).

If you want to use `colorbash` without AGPLv3 obligations, a separate commercial license may be available from Alex Mutua. Contact: `alexmusyoki834@gmail.com`. See [LICENSING.md](LICENSING.md).
