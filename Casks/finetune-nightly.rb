cask "finetune-nightly" do
  version "1.9.1-nightly.20261107.2"
  sha256 "7e010f019f0ae84814a17b42329f8c22006f7664b33b163d53d35ca466df4fee"

  url "https://github.com/KKKKeybird/homebrew-tap/releases/download/finetune-nightly-#{version}-437451463/FineTune-Nightly.zip"
  name "FineTune Nightly"
  desc "Per-app volume control, audio routing and EQ (community nightly)"
  homepage "https://github.com/KKKKeybird/FineTune"

  conflicts_with cask: ["finetune", "finetune-hwong"]
  depends_on macos: :sequoia

  app "FineTune Nightly.app"

  caveats <<~EOS
    This build requires macOS 15.4 or later.
    This community nightly is ad-hoc signed and is not notarized by Apple.
    Allow it in System Settings > Privacy & Security if macOS blocks first launch.
    Grant audio capture, microphone and Bluetooth access when prompted as needed.
    Updates are managed by Homebrew; run brew upgrade --cask finetune-nightly.
    In-app Sparkle updates are disabled to prevent channel crossover.
  EOS
end
