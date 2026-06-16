# AUR Draft

Package name target:

```text
codex-desktop-bin
```

The included `PKGBUILD.template` assumes a GitHub Release artifact exists:

```text
codex-desktop-bin-$pkgver-$pkgrel-x86_64.pkg.tar.zst
```

Before submitting to AUR:

1. Confirm binary redistribution is permitted.
2. Create a GitHub Release with the package artifact.
3. Replace `REPLACE_WITH_SHA256` with the release artifact SHA256.
4. Generate `.SRCINFO`:

```bash
cp PKGBUILD.template PKGBUILD
makepkg --printsrcinfo > .SRCINFO
```

5. Review the package with `namcap` if available.
6. Push to the AUR git repository:

```bash
git clone ssh://aur@aur.archlinux.org/codex-desktop-bin.git
```

If redistribution is not allowed, use this repository as a local build tool
instead of publishing a `-bin` package.
