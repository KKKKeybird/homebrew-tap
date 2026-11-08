cask "finetune-nightly" do
  version "1.9.1-nightly.20261107.3"
  sha256 "c7d3eb1cf32156a752d84056a75d7f51146d3074fac40fad76b954693f3aee7e"

  url "https://github.com/KKKKeybird/homebrew-tap/releases/download/finetune-nightly-#{version}-437894354/FineTune-Nightly.zip"
  name "FineTune Nightly"
  desc "Per-app volume control, audio routing and EQ (community nightly)"
  homepage "https://github.com/KKKKeybird/FineTune"

  livecheck do
    skip "Version checks are handled by the FineTune Nightly sync workflow."
  end

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
