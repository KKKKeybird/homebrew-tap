# Homebrew Tap

Personal Homebrew tap for packages maintained by KeyBird.

## Available casks

| Cask               | Application       |
| ------------------ | ----------------- |
| `finetune-nightly` | FineTune community nightly |
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

For the automatically mirrored hwong103 FineTune builds, installation and update details, see [finetune-hwong.md](finetune-hwong.md).

For the community Nightly build, install and update with:

```sh
brew install --cask KKKKeybird/tap/finetune-nightly
brew upgrade --cask finetune-nightly
```

The Nightly uses a separate bundle identifier so it does not replace the
upstream or hwong103 builds. It is ad-hoc signed and not notarized, and its
updates are managed by Homebrew rather than Sparkle.
