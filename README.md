# Homebrew Tap

Personal Homebrew tap for packages maintained by KeyBird.

## Available formulae

| Formula                 | Package                                                     |
| ----------------------- | ----------------------------------------------------------- |
| `inshellisense-rounded` | inshellisense with rounded suggestion and description boxes |

```sh
brew tap KKKKeybird/tap
brew install inshellisense-rounded
```

The formula is rebuilt automatically when the rounded-corner fork synchronizes
with upstream.

## Available casks

| Cask               | Application       |
| ------------------ | ----------------- |
| `fn-sync`          | 飞牛同步          |
| `haima-cloud`      | 海马云电脑        |
| `moonlight-vplus`  | Moonlight V+      |
| `qiyou`            | 奇游加速器        |
| `scriptplayerplus` | ScriptPlayer+     |
| `tmog`             | Task Manager TMOG |
| `xenolauncher`     | Xenolauncher      |

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
