# Homebrew Tap

Personal Homebrew tap for packages maintained by KeyBird.

## Rounded inshellisense

The macOS package is distributed as a binary cask so installation does not
require an Xcode toolchain:

```sh
brew tap KKKKeybird/tap
brew install --cask KKKKeybird/tap/inshellisense-rounded
```

The rounded-corner fork builds and publishes its own releases. This tap only
downloads those release assets and updates the cask and checksums.

## Available casks

| Cask                    | Application                      |
| ----------------------- | -------------------------------- |
| `inshellisense-rounded` | inshellisense with rounded boxes |
| `fn-sync`               | 飞牛同步                         |
| `haima-cloud`           | 海马云电脑                       |
| `moonlight-vplus`       | Moonlight V+                     |
| `qiyou`                 | 奇游加速器                       |
| `scriptplayerplus`      | ScriptPlayer+                    |
| `tmog`                  | Task Manager TMOG                |
| `xenolauncher`          | Xenolauncher                     |

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
