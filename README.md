# Homebrew Tap

Personal Homebrew tap for packages maintained by KeyBird.

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
not block other updates. Cask releases are checked every six hours, and each run
changes only its own package.
