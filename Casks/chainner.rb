cask "chainner" do
  version "0.26.1"
  sha256 "b71538607e05bbce8f000bdfedd73f7817600436c15ce9a6e0f79bfe7e7fd463"

  url "https://github.com/chaiNNer-org/chaiNNer/releases/download/v#{version}/chaiNNer-#{version}-macos-universal.dmg"
  name "chaiNNer"
  desc "Node-based image processing and AI upscaling GUI"
  homepage "https://github.com/chaiNNer-org/chaiNNer"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on :macos

  app "chaiNNer.app"

  zap trash: [
    "~/Library/Application Support/chaiNNer",
    "~/Library/Caches/chainner_pip",
    "~/Library/Logs/chaiNNer",
    "~/Library/Preferences/com.electron.chainner.plist",
    "~/Library/Saved Application State/com.electron.chainner.savedState",
  ]

  caveats <<~EOS
    The current macOS build is not code signed or notarized by Apple.
    Allow it in System Settings > Privacy & Security if macOS blocks first launch.
    Updates are managed by Homebrew; run brew upgrade --cask chainner.
  EOS
end
