cask "moonlight-vplus" do
  version "6.3.13"
  sha256 "f03aa5078d8141304ecae78cc6e77384c5135a038177e080dd2123729c238835"

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
