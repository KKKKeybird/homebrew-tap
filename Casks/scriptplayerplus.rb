cask "scriptplayerplus" do
  version "0.6.2"
  sha256 "000b641758e9fcffccf669cd93da77030de8df5fb790f379c58dfffa347e569d"

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
