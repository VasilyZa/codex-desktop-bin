# Distribution Notes

This repository is safe to publish as automation and packaging glue.

Publishing converted Codex Desktop binary packages is a separate question:

- The generated package contains OpenAI Codex Desktop application payload copied
  from the upstream macOS DMG.
- The upstream Linux wrapper project describes itself as a conversion tool and
  states that it does not redistribute OpenAI software.
- A public GitHub Release artifact or AUR `-bin` package would redistribute that
  payload.

Recommended default:

1. Publish this repository without binary artifacts.
2. Build packages locally for personal use.
3. Keep GitHub Actions artifact upload disabled unless the repository is private
   or redistribution has been cleared.
4. If sharing through AUR, prefer a build-from-source/local-conversion package
   unless binary redistribution is explicitly allowed.

The `aur/PKGBUILD.template` file is intentionally a template, not a ready-to-push
AUR package.
