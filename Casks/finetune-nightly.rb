cask "finetune-nightly" do
  version "1.9.1-nightly.20261108.e346c320b48d"
  sha256 "4e15787012e7898c9ba3211e1e3c18cce18e72c33cd849688d2a81fc7b4e4efb"

  url "https://github.com/KKKKeybird/homebrew-tap/releases/download/finetune-nightly-#{version}-438101914/FineTune-Nightly.zip"
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
