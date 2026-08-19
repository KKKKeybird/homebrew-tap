# Homebrew Tap

Personal Homebrew tap for packages maintained by KeyBird.

## Rounded inshellisense

The macOS package is distributed as a Formula with a prebuilt Homebrew Bottle,
matching the installation model used by `homebrew/core/inshellisense`:

```sh
brew tap KKKKeybird/tap
brew install KKKKeybird/tap/inshellisense-rounded
```

The rounded-corner fork builds, tests, and publishes its own release packages
and `arm64_tahoe` Bottle. This tap only updates the Formula URLs and checksums.

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

Each package has an independent sync workflow, so one unavailable upstream does
not block other updates. Cask releases are checked every six hours; rounded
inshellisense releases are checked daily. Each run changes only its own package.
