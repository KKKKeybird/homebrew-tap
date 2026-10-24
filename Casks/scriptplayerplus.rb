cask "scriptplayerplus" do
  version "0.7.1"
  sha256 "752da433c1180f323312dd97d9ed56aacb3c1fc924596d0015feb723ab7eff33"

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
