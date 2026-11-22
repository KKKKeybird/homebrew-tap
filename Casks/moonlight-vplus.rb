cask "moonlight-vplus" do
  version "6.5.7"
  sha256 "449757ee8b4361494db9600b41aa5aed147b329da125177fb1acc232d81790a2"

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
