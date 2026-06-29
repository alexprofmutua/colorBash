# Publishing colorbash

This file describes the maintainer workflow for publishing new `colorbash` releases.

## Current Published Setup

- Main repo: [amm22-lab/colorBash](https://github.com/amm22-lab/colorBash)
- Homebrew tap: [amm22-lab/homebrew-colorbash](https://github.com/amm22-lab/homebrew-colorbash)
- Current release line: `v0.1.4`
- User install command (macOS / Linux):

```bash
brew tap amm22-lab/colorbash
brew install colorbash
echo 'eval "$(colorbash init)"' >> ~/.zshrc
source ~/.zshrc
```

- User install command (Windows, Scoop):

```powershell
scoop bucket add colorbash https://github.com/amm22-lab/colorBash
scoop install colorbash
```

- No-Homebrew install command (macOS / Linux):

```bash
curl -fsSL https://raw.githubusercontent.com/amm22-lab/colorBash/main/bootstrap.sh | bash -s -- --configure-shell
```

## One-Time Repo Setup

If you are starting from scratch on a new machine:

```bash
cd /Users/alexprof/Projects/colorBash
git remote -v
gh auth status
```

The expected repositories are:

- main app repo: `amm22-lab/colorBash`
- Homebrew tap repo: `amm22-lab/homebrew-colorbash`

If the tap repo does not exist yet, create it once:

```bash
cd /tmp
gh repo create amm22-lab/homebrew-colorbash --public --clone --description "Homebrew tap for colorbash"
```

## Release Workflow

### 1. Update the project version

Edit `VERSION` to the new version number, for example:

```text
0.1.3
```

### 2. Build the release archive

```bash
cd /Users/alexprof/Projects/colorBash
./scripts/package-release.sh
```

This prints:

- the versioned release archive path
- the stable release archive path
- the SHA256 checksum

For example, a release might produce:

```bash
dist/colorbash-v0.1.3.tar.gz
dist/colorbash.tar.gz
```

### 3. Regenerate package definitions

Use the SHA256 printed by the package script:

```bash
./scripts/generate-homebrew-formula.sh amm22-lab colorBash 0.1.3 <sha256>
./scripts/generate-scoop-manifest.sh amm22-lab colorBash 0.1.3 <sha256>
```

This updates:

```bash
Formula/colorbash.rb
bucket/colorbash.json
```

The formula installs from the GitHub Release asset, not from the raw source archive:

```text
https://github.com/amm22-lab/colorBash/releases/download/v0.1.3/colorbash-v0.1.3.tar.gz
```

### 4. Commit and push the main repo

```bash
git add .
git commit -m "Release 0.1.3"
git push origin main
```

### 5. Tag and publish the GitHub Release

```bash
git tag v0.1.3
git push origin v0.1.3
gh release create v0.1.3 dist/colorbash-v0.1.3.tar.gz dist/colorbash.tar.gz \
  --title "colorbash v0.1.3" \
  --notes "Describe the release here."
```

If you prefer the GitHub web UI, create the release there and upload both `dist/colorbash-v0.1.3.tar.gz` and `dist/colorbash.tar.gz` manually.

### 6. Update the Homebrew tap repo

If you already cloned the tap repo:

```bash
cp /Users/alexprof/Projects/colorBash/Formula/colorbash.rb /tmp/homebrew-colorbash/Formula/colorbash.rb
cd /tmp/homebrew-colorbash
git add Formula/colorbash.rb
git commit -m "Update colorbash to 0.1.3"
git push origin main
```

If the tap repo is not cloned locally yet:

```bash
cd /tmp
gh repo clone amm22-lab/homebrew-colorbash
cp /Users/alexprof/Projects/colorBash/Formula/colorbash.rb /tmp/homebrew-colorbash/Formula/colorbash.rb
cd /tmp/homebrew-colorbash
git add Formula/colorbash.rb
git commit -m "Update colorbash to 0.1.3"
git push origin main
```

## Verification

After publishing:

```bash
brew update
brew info amm22-lab/colorbash/colorbash
brew upgrade amm22-lab/colorbash/colorbash
```

The expected result is that Homebrew reports the new stable version and installs that same version locally.

## Quick Checklist

For each new release:

1. update `VERSION`
2. run `./scripts/package-release.sh`
3. copy the printed SHA256
4. run `./scripts/generate-homebrew-formula.sh amm22-lab colorBash <version> <sha256>`
5. run `./scripts/generate-scoop-manifest.sh amm22-lab colorBash <version> <sha256>`
6. commit and push `main` (includes `bucket/colorbash.json` for Scoop users)
7. tag `v<version>` and push the tag
8. create the GitHub Release and upload both `dist/colorbash-v<version>.tar.gz` and `dist/colorbash.tar.gz`
9. copy the updated formula into `homebrew-colorbash`
10. commit and push the tap repo
11. run `brew update` and `brew info amm22-lab/colorbash/colorbash`
