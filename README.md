# Homebrew Tap

Personal Homebrew tap for packages maintained by KeyBird.

## Available casks

| Cask               | Application       |
| ------------------ | ----------------- |
| `convt-free`      | convt 免费源码构建 |
| `finetune-hwong` | FineTune hwong103 fork |
| `fn-sync`          | 飞牛同步          |
| `haima-cloud`      | 海马云电脑        |
| `macchiato`        | Macchiato         |
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

For convt-free installation, Finder Quick Actions, local certificate signing and acceptance status, see [convt-free.md](convt-free.md) and the [build documentation](https://github.com/KKKKeybird/convt/blob/main/distribution/free/README.md). The public package is ad-hoc signed and is not Apple notarized.

For the automatically mirrored hwong103 FineTune builds, installation and update details, see [finetune-hwong.md](finetune-hwong.md).

