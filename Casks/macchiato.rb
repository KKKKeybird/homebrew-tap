cask "macchiato" do
  version "0.1.0"
  sha256 "a8c04061485d9f0207aeccf7990e6f1501830a97d7e7f08a40adba5b10839e69"

  url "https://github.com/ObservedObserver/Macchiato/releases/download/#{version}/Macchiato.dmg"
  name "Macchiato"
  desc "Menu bar utility to prevent sleep"
  homepage "https://github.com/ObservedObserver/Macchiato"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Macchiato.app"

  caveats <<~EOS
    Enable Keep Awake from the menu bar after launching Macchiato.
    macOS may ask you to approve Macchiato Helper in System Settings
    the first time you enable lid-closed sleep control.
  EOS
end
