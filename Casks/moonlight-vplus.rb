cask "moonlight-vplus" do
  version "6.5.2"
  sha256 "08d740ae9eb5b3b89e8bf58d59edd0d42cf9aefb2409864001d155910860d917"

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
