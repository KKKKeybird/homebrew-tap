cask "moonlight-vplus" do
  version "6.5.1"
  sha256 "3165f61ec302c2e9e327532e6323c088c65be89e776a5b70bb043419f9fbce8e"

  url "https://github.com/qiin2333/moonlight-qt/releases/download/v#{version}/Moonlight-VPlus-#{version}-arm64.dmg"
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

  preflight_steps do
    run "/usr/bin/xattr",
        args: ["-cr", "{{staged_path}}/Moonlight.app"]
    run "/usr/bin/codesign",
        args: ["--force", "--deep", "--sign", "-", "{{staged_path}}/Moonlight.app"]
  end

  caveats <<~EOS
    This fork is ad-hoc signed on your Mac during installation. Homebrew also
    removes its quarantine attribute because the upstream build is not notarized.
  EOS
end
