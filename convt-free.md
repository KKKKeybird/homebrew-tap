# convt-free

Unofficial ordinary source build of opencoredev/convt. The Cask is generated only after a complete verified macOS ARM64 release exists in KKKKeybird/convt; there is no placeholder download.

After publication:

```sh
brew tap KKKKeybird/tap
brew install --cask convt-free
brew upgrade --cask convt-free
brew uninstall --cask convt-free
```

Installs /Applications/convt.app, convt-free CLI and a user-level Finder Quick Action. Office support requires `brew install --cask libreoffice`. Ad-hoc signed, not Apple notarized; normal macOS approval may be required. Native FinderSync is preserved, but the full format submenu requires team signing. The Quick Action opens selected files in the GUI instead. Do not install alongside the official convt app. No automatic Gatekeeper bypass.

See https://github.com/KKKKeybird/convt/blob/main/distribution/free/README.md for actual verification status, AGPL and third-party source obligations, acceptance steps and troubleshooting. The updater checks every six hours, hashes the downloaded ZIP, and preserves the existing Cask if verification fails.
