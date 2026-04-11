# Publishing colorbash

This guide takes `colorbash` from a local project to:

- a public GitHub repository
- a downloadable GitHub Release
- a Homebrew tap users can install from

## 1. Initialize And Push The Main Repo

If this directory is not already a git repository:

```bash
cd /Users/alexprof/Projects/colorBash
git init -b main
git add .
git commit -m "Initial release of colorbash"
```

Create a GitHub repository and push it:

```bash
gh repo create colorBash --public --source=. --remote=origin --push
```

If you prefer the GitHub website, create the repo there first and then run:

```bash
git remote add origin git@github.com:<your-github-name>/colorBash.git
git push -u origin main
```

## 2. Create A Release Archive

The project version is stored in `VERSION`.

Build a release archive:

```bash
./scripts/package-release.sh
```

That prints:

- the release archive path
- the SHA256 checksum

For `VERSION=0.1.0`, the archive will be:

```bash
dist/colorbash-v0.1.0.tar.gz
```

## 3. Tag And Publish A GitHub Release

Create and push a version tag:

```bash
git tag v0.1.0
git push origin main --tags
```

Create a GitHub Release with the packaged archive attached:

```bash
gh release create v0.1.0 dist/colorbash-v0.1.0.tar.gz \
  --title "colorbash v0.1.0" \
  --notes "First public release of colorbash."
```

If you do not use the GitHub CLI, create the release in the GitHub web UI and upload the `dist/` archive manually.

## 4. Create The Homebrew Tap Repo

Create a separate repository named:

```bash
homebrew-colorbash
```

Clone it locally:

```bash
gh repo create homebrew-colorbash --public
gh repo clone <your-github-name>/homebrew-colorbash ../homebrew-colorbash
```

Or clone it after creating it in the GitHub web UI:

```bash
git clone git@github.com:<your-github-name>/homebrew-colorbash.git ../homebrew-colorbash
```

## 5. Generate The Homebrew Formula

Use the SHA256 printed by `./scripts/package-release.sh`:

```bash
./scripts/generate-homebrew-formula.sh <your-github-name> colorBash 0.1.0 <sha256>
```

That writes:

```bash
Formula/colorbash.rb
```

Copy it into the tap repository:

```bash
mkdir -p ../homebrew-colorbash/Formula
cp Formula/colorbash.rb ../homebrew-colorbash/Formula/colorbash.rb
```

Then commit and push the tap:

```bash
cd ../homebrew-colorbash
git add Formula/colorbash.rb
git commit -m "Add colorbash 0.1.0"
git push origin main
```

## 6. What Users Will Run

After the main repo and tap are public, users can install with:

```bash
brew tap <your-github-name>/colorbash
brew install colorbash
```

Or directly:

```bash
brew install <your-github-name>/colorbash/colorbash
```

## 7. Release Checklist For Future Versions

For each new release:

1. update `VERSION`
2. commit your changes
3. run `./scripts/package-release.sh`
4. copy the new SHA256
5. regenerate `Formula/colorbash.rb`
6. commit and push the main repo
7. tag the release and publish the GitHub Release
8. copy the updated formula into `homebrew-colorbash`
9. commit and push the tap repo
