cask "moonlight-vplus" do
  version "6.4.0"
  sha256 "d73c3454515969c088f3b87c6d2691f8d04eb8e994288d8f29c39f6ff8855602"

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
