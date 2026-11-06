cask "scriptplayerplus" do
  version "0.7.2"
  sha256 "84f25082fed94cb180ab4780ff6c494fc65f39fd825026d764bfd77af2887a4b"

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
