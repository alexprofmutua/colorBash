
# colorbash

**Custom colors for files and folders in your terminal.**

colorbash is a lightweight command-line utility that lets you assign colors to specific file and folder names in `ls` output.

Built for macOS and Linux, with Windows support through Git Bash and WSL.

## Preview

**Before**

![Default terminal output](examples/before.svg)

**After**

![Terminal output with colorbash](examples/after.svg)

## Installation

### macOS / Linux — Homebrew

```bash
brew install amm22-lab/colorbash/colorbash
echo 'eval "$(colorbash init)"' >> ~/.zshrc
source ~/.zshrc
```

For Bash, use `~/.bashrc` instead of `~/.zshrc`.

### macOS / Linux — Without Homebrew

```bash
curl -fsSL https://raw.githubusercontent.com/amm22-lab/colorBash/main/bootstrap.sh | bash -s -- --configure-shell
```

### Windows — Scoop

```powershell
scoop bucket add colorbash https://github.com/amm22-lab/colorBash
scoop install colorbash
```

Run colorbash from Git Bash after installation.

For other installation methods, see [CROSS-PLATFORM.md](CROSS-PLATFORM.md).

## Usage

Assign a color to a file or folder:

```bash
cb Documents blue
cb Projects '#ff7a00'
cb Downloads teal
```

Assign random colors to items in the current directory:

```bash
cb random
```

Manage your colors:

| Command | Description |
|---|---|
| `cb <name> <color>` | Set a color for an exact name |
| `cb random` | Color visible items in the current directory |
| `cb list` | Show saved rules |
| `cb remove <name>` | Remove a rule |
| `cb clear` | Clear all saved rules |

Supports standard ANSI colors, extended named colors, 256-color codes, and hexadecimal colors.

## How It Works

colorbash stores your preferences locally and applies them when you run `ls`.

It supports `ls`, `ls -a`, `ls -A`, and `ls -1` in interactive terminals. Other `ls` options continue to use your system's native implementation.

No background services or changes to your files.

## Documentation

- [Cross-platform support](CROSS-PLATFORM.md)
- [Publishing and releases](PUBLISHING.md)
- [Licensing](LICENSING.md)

## License

Licensed under the [GNU Affero General Public License v3.0](LICENSE).

Commercial licensing is available separately. See [LICENSING.md](LICENSING.md).
