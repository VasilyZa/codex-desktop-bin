# Disclaimer

## Acknowledgements

This project is built on the idea and engineering approach demonstrated by
[ilysenko/codex-desktop-linux](https://github.com/ilysenko/codex-desktop-linux).
That project showed how the official macOS Codex Desktop app can be converted
into a Linux Electron app on the user's own machine. This repository focuses on
Arch/CachyOS packaging, AUR-friendly installation, and optional trusted prebuilt
distribution paths.

Thank you to the `codex-desktop-linux` maintainers and contributors for making
the Linux conversion workflow understandable and reusable.

## Unofficial Project

This is an unofficial community project. It is not created, endorsed, sponsored,
reviewed, or supported by OpenAI.

OpenAI, Codex, and related names, marks, logos, application assets, and product
materials belong to OpenAI or their respective rights holders. This repository
does not claim ownership of those materials.

## User Responsibility

Use this project at your own risk. The default AUR/package flow builds locally
from the official upstream `Codex.dmg` on the user's machine. Users are
responsible for:

- complying with OpenAI's terms and any applicable licenses;
- reviewing the package scripts before running them;
- deciding whether to trust optional prebuilt artifacts;
- keeping their system, credentials, and Codex configuration safe.

The maintainers provide this packaging automation as-is, without warranty of
fitness, security, compatibility, availability, or continued functionality.

## Binary Distribution

Public prebuilt artifacts may contain converted Codex Desktop application
payload derived from the upstream macOS DMG. Redistribution rights for that
payload are separate from this repository's own MIT-licensed scripts and
documentation.

For that reason, local build is the public default. Prebuilt mode is opt-in and
intended for trusted environments.

## Rights Holder Contact

If you are OpenAI or another rights holder and believe this repository, package,
release artifact, or AUR submission infringes your rights or violates applicable
terms, please contact the maintainer. The disputed content will be reviewed and,
where appropriate, removed or disabled.

Preferred contact paths:

- Open a GitHub issue in this repository.
- Email the maintainer listed in the AUR `PKGBUILD`.

