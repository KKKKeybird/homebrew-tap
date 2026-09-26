cask "scriptplayerplus" do
  version "0.6.3"
  sha256 "c70006a487c1bc003c84cd1191f84da620b44feaf100875d09ff28a3b8dc762e"

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
