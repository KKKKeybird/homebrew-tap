cask "scriptplayerplus" do
  version "0.5.1"
  sha256 "2e43d96b1037d7b067872684fe96c0f6bf386d16206472cada3d999313a5938c"

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
