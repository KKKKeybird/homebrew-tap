cask "scriptplayerplus" do
  version "0.6.0"
  sha256 "fc0c86480268f480125b526ddba14463c58d0afa02da9d50626d5a4ab235e04f"

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
