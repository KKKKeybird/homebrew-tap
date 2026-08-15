# Homebrew Tap

Personal Homebrew tap for packages maintained by KeyBird.

## Available casks

| Cask | Application |
| --- | --- |
| `haima-cloud` | 海马云电脑 |
| `moonlight-vplus` | Moonlight V+ |
| `scriptplayerplus` | ScriptPlayer+ |
| `tmog` | Task Manager TMOG |
| `xenolauncher` | Xenolauncher |

```sh
brew tap KKKKeybird/tap
brew install --cask <cask>
```

Upgrade it with:

```sh
brew update
brew upgrade --cask <cask>
```

Upstream releases are checked every six hours. When a new release is found,
the cask version and SHA-256 checksum are updated automatically.
