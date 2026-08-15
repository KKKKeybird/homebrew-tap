require_relative "../lib/fn_signed_download_strategy"

cask "fn-sync" do
  version "0.2.3"
  sha256 "4bca0c5f0d57a0aafd7c20545edf5c1f8b82151e7baf9bb7ff2113deb5605994"

  url "https://iso.liveupdate.fnnas.com/pc/fn-sync_#{version}_aarch64.dmg",
      using: FnSignedDownloadStrategy
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
end
