cask "finetune-hwong" do
  version "1.9.1,41743220786.1"
  sha256 "9d8a46f46975f459ff196f27da78f76be4273c5b3c05b0598d366993c817b27e"

  url "https://github.com/KKKKeybird/homebrew-tap/releases/download/finetune-hwong-#{version.csv.first}-41743220786-1/FineTune-hwong.zip",
      verified: "github.com/KKKKeybird/homebrew-tap/"
  name "FineTune (hwong103)"
  desc "Per-app volume control, audio routing and EQ (hwong103 fork)"
  homepage "https://github.com/hwong103/FineTune"

  conflicts_with cask: "finetune"
  depends_on arch: :arm64
  depends_on macos: :sequoia

  app "FineTune.app"

  caveats <<~EOS
    This build requires macOS 15.4 or later.
    This upstream community build is ad-hoc signed and is not notarized by Apple.
    Allow it in System Settings > Privacy & Security if macOS blocks first launch.
    Grant audio capture, microphone and Bluetooth access when prompted as needed.
    Updates are delivered by this tap; run brew upgrade --cask finetune-hwong.
  EOS
end
