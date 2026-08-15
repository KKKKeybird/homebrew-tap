cask "fn-sync" do
  version "0.2.3"
  sha256 "ff3791311ce0d2dd4469f39aa79af07bea68f8625e689219221736ebaa34e637"

  url "https://github.com/KKKKeybird/homebrew-tap/releases/download/fn-sync-#{version}/fn-sync-#{version}-arm64.zip",
      verified: "github.com/KKKKeybird/homebrew-tap/"
  name "Feiniu Sync"
  name "飞牛同步"
  desc "Synchronize files with an fnOS NAS"
  homepage "https://fnnas.com/download?key=fn-sync-client"

  livecheck do
    url :homepage
    regex(/fn-sync[._-]v?(\d+(?:\.\d+)+)_aarch64\.dmg/i)
  end

  auto_updates true
  depends_on arch: :arm64
  depends_on macos: :monterey

  app "飞牛同步.app"

  zap trash: [
    "~/Library/Application Support/com.fn-sync-client.app",
    "~/Library/Caches/com.fn-sync-client.app",
    "~/Library/Preferences/com.fn-sync-client.app.plist",
  ]

  caveats <<~EOS
    This cask uses a Developer ID-signed mirror because the upstream CDN blocks
    automated Homebrew downloads.
  EOS
end
