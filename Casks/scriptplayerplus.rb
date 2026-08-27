cask "scriptplayerplus" do
  version "0.6.1"
  sha256 "6291c33b7468105ee95bf81d5d667f03bea1cb170037d33b9842ee64fb00165c"

  url "https://github.com/sioaeko/scriptplayer-plus/releases/download/v#{version}/ScriptPlayerPlus-#{version}-arm64-mac.dmg",
      verified: "github.com/sioaeko/scriptplayer-plus/"
  name "ScriptPlayer+"
  desc "Funscript video player with device and script-source integrations"
  homepage "https://github.com/sioaeko/scriptplayer-plus"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: :big_sur

  app "ScriptPlayerPlus.app"
end
