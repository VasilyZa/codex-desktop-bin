# Distribution Notes

This repository is safe to publish as automation and packaging glue.

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
