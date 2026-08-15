cask "moonlight-vplus" do
  version "6.3.7"
  sha256 "d9697044703c619a6d3195a5d87215bcb56b0f49594e104727aeb01be8fda1bb"

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

  preflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{staged_path}/Moonlight.app"]
    system_command "/usr/bin/codesign",
                   args: ["--force", "--deep", "--sign", "-", "#{staged_path}/Moonlight.app"]
  end

  app "Moonlight.app"

  caveats <<~EOS
    This fork is ad-hoc signed on your Mac during installation. Homebrew also
    removes its quarantine attribute because the upstream build is not notarized.
  EOS
end
