# FineTune (hwong103)

这个 Cask 跟踪 [hwong103/FineTune](https://github.com/hwong103/FineTune) 的
`main` 分支成功 `Build App` 构建。直接转存上游安装包，不在 tap 重新编译。

```sh
brew tap KKKKeybird/tap
brew install --cask KKKKeybird/tap/finetune-hwong

# 后续更新
brew update
brew upgrade --cask finetune-hwong
```

若已安装原版 `finetune`，先退出应用，再执行 `brew uninstall --cask finetune`。
两个 Cask 都安装 `FineTune.app`，因此声明为互斥。不使用 `--zap`，保留已有偏好设置。

## 自动同步

- 每六小时检查一次（北京时间 02:23、08:23、14:23、20:23；GitHub 定时任务可能延迟）。
- 支持手动运行 `Sync FineTune hwong103 build`；首次提交也会自动运行。
- 只接受 `build-app.yml` 在 `main` 上由 push / workflow_dispatch 触发的成功构建。
- 下载 Actions Artifact 包装 ZIP，校验 GitHub 提供的 SHA-256，取出原始安装 ZIP。
  验证 ZIP 路径、CRC、应用 Bundle ID、macOS 最低版本、Mach-O 架构和代码签名。
- 发布到本 tap 的独立 Release，附 `SHA256SUMS` 与 `provenance.json`；不会成为 tap 的
  latest Release，也不会覆盖已经发布的二进制。只有发布成功后才提交 Cask。
- Cask 版本形如 `1.9.1,41743220786.1`，依次表示 App 版本、Run ID、重跑次数，
  所以上游不改 App 版本号也能通过 Homebrew 更新。
- `.github/finetune-hwong.json` 记录源提交、构建链接、Artifact ID、架构及校验值。
- 已同步构建直接跳过。最新包过期、缺失、校验失败或 API 不可用时任务失败，保留上一版。
  不会静默退回旧包；可等待上游新构建，或请上游重新运行构建后再手动同步。

仅使用 GitHub Actions 自带的 `GITHUB_TOKEN`，无需额外 PAT。上游为公开仓库；若 GitHub
拒绝跨仓库 Artifact 读取，同步会明确失败，需要按报错排查访问权限。

## 首次启动

上游构建采用 ad-hoc 签名，未经 Apple 公证。首次启动如被阻止，请在
“系统设置 → 隐私与安全性”中允许打开；随后按需授予音频捕获、麦克风和蓝牙权限。
本 tap 不移除隔离属性、不关闭 Gatekeeper，也不重新签名应用。
上游 fork 已移除 Sparkle 的原版更新源，后续使用 Homebrew 更新。

## 故障与回滚

先查看 `Sync FineTune hwong103 build` 的失败步骤；可手动重跑同一同步工作流。
已发布但未能提交 Cask 时，重跑会校验已有 Release 内容，然后重试提交，不会覆盖发布包。

需要回退时，暂停此工作流，把 `Casks/finetune-hwong.rb` 与
`.github/finetune-hwong.json` 一起恢复到目标旧提交，然后运行：

```sh
brew update
brew reinstall --cask finetune-hwong
```

确认可用后再恢复工作流；恢复同步会继续跟踪最新成功构建。
