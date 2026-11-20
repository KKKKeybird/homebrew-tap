cask "scriptplayerplus" do
  version "0.7.3"
  sha256 "eb72b2c52409525828b97901c03078f61e67fc704eb465232ce93c90c95f6311"

  url "https://github.com/sioaeko/scriptplayer-plus/releases/download/v#{version}/ScriptPlayerPlus-#{version}-arm64-mac.dmg"
  name "ScriptPlayer+"
  desc "Funscript video player with device and script-source integrations"
  homepage "https://github.com/sioaeko/scriptplayer-plus"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: :monterey

  app "ScriptPlayerPlus.app"
end
