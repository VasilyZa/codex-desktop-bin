# Distribution Notes

This repository is safe to publish as automation and packaging glue.

The Linux conversion approach is based on the work of
[ilysenko/codex-desktop-linux](https://github.com/ilysenko/codex-desktop-linux).
This repository packages that local conversion workflow for Arch/CachyOS and
AUR-style installation.

Publishing converted Codex Desktop binary packages is a separate question:

- The generated package contains OpenAI Codex Desktop application payload copied
  from the upstream macOS DMG.
- The upstream Linux wrapper project describes itself as a conversion tool and
  states that it does not redistribute OpenAI software.
- A public GitHub Release artifact or AUR `-bin` package would redistribute that
  payload.

Recommended public default:

1. Publish this repository without binary artifacts.
2. Make the AUR package build from the official upstream DMG on the user's
   machine.
3. Keep GitHub Actions artifact upload disabled unless the repository is private
   or redistribution has been cleared.
4. Treat prebuilt mode as an explicit opt-in for trusted machines:
   `PREBUILT=1 yay -S codex-desktop-bin`.

The `aur/PKGBUILD` file follows this shape: local build by default, optional
prebuilt install only when the user sets `PREBUILT=1`.

## Disclaimer Text

Use the root [DISCLAIMER.md](../DISCLAIMER.md) as the canonical disclaimer.
Important points:

- This project is unofficial and not affiliated with OpenAI.
- OpenAI/Codex names and assets belong to their respective rights holders.
- Users run local builds and optional prebuilt installs at their own risk.
- Public prebuilt artifacts may redistribute converted Codex Desktop payload,
  so local build remains the public default.
- Rights holders can contact the maintainer for review/removal.
