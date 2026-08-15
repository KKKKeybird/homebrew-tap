cask "qiyou" do
  version "1.5.1"
  sha256 "1f8252e134040a641e637d18754e70f9a30d27c223ebfc761ab39cf85b016f6e"

  url "https://static.qiyou.cn/official_web/install_package//MacGameAccelerator-vrelease-151-Release_afceed.dmg",
      verified: "static.qiyou.cn/"
  name "Qiyou Game Accelerator"
  name "奇游加速器"
  desc "Game network accelerator"
  homepage "https://www.qiyou.cn/main/console"

  livecheck do
    url "https://apifast.qiyou.cn/api/common_bll/v1/official_web/download_url?client_type=MAC"
    regex(/vrelease[._-]?(\d)(\d)(\d+)-Release/i)
    strategy :json do |json, regex|
      match = json["download_url"]&.match(regex)
      next if match.blank?

      "#{match[1]}.#{match[2]}.#{match[3]}"
    end
  end

  auto_updates true
  depends_on macos: :big_sur

  app "奇游加速器.app"

  uninstall launchctl: "com.qeeyou.MobileGameAccelerator.ProxyConfigHelper",
            delete:    [
              "/Library/LaunchDaemons/com.qeeyou.MobileGameAccelerator.ProxyConfigHelper.plist",
              "/Library/PrivilegedHelperTools/com.qeeyou.MobileGameAccelerator.ProxyConfigHelper",
            ]

  zap trash: [
    "~/Library/Application Support/奇游加速器",
    "~/Library/Caches/com.qeeyou.MobileGameAccelerator",
    "~/Library/Preferences/com.qeeyou.MobileGameAccelerator.plist",
    "~/Library/WebKit/com.qeeyou.MobileGameAccelerator",
  ]
end
