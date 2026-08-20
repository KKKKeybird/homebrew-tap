cask "moonlight-vplus" do
  version "6.3.8"
  sha256 "4607609ea58b8a758ba0a498bc0805f1b5c415843e2dea048bcff73f48e7ca94"

  url "https://github.com/qiin2333/moonlight-qt/releases/download/v#{version}/Moonlight-VPlus-#{version}-arm64.dmg",
      verified: "github.com/qiin2333/moonlight-qt/"
  name "Moonlight V+"
  desc "Enhanced Moonlight client for Foundation Sunshine"
  homepage "https://github.com/qiin2333/moonlight-qt"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on arch: :arm64
  depends_on macos: :ventura

  app "Moonlight.app"

  preflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{staged_path}/Moonlight.app"]
    system_command "/usr/bin/codesign",
                   args: ["--force", "--deep", "--sign", "-", "#{staged_path}/Moonlight.app"]
  end

  caveats <<~EOS
    This fork is ad-hoc signed on your Mac during installation. Homebrew also
    removes its quarantine attribute because the upstream build is not notarized.
  EOS
end
