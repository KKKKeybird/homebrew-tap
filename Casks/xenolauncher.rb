cask "xenolauncher" do
  version "1.3.1"
  sha256 "fad7a0504790a214438802d7208be79bbea803816c106e48271a42e43e7a3d17"

  url "https://github.com/m5kro/Xenolauncher/releases/download/#{version}/Xenolauncher-arm64.zip",
      verified: "github.com/m5kro/Xenolauncher/"
  name "Xenolauncher"
  desc "Game launcher and compatibility layer"
  homepage "https://github.com/m5kro/Xenolauncher"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: :monterey

  app "Xenolauncher-arm64.app"

  caveats <<~EOS
    The upstream build is not notarized. macOS may require opening it from the
    Finder context menu the first time.
  EOS
end
