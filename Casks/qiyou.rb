cask "qiyou" do
  version "1.5.1"
  sha256 "1f8252e134040a641e637d18754e70f9a30d27c223ebfc761ab39cf85b016f6e"

  url "https://static.qiyou.cn/upload/1786413954327/app_version/MacGameAccelerator-vrelease-#{version}-Release.dmg"
  name "Qiyou Game Accelerator"
  name "奇游加速器"
  desc "Game network accelerator"
  homepage "https://www.qiyou.cn/main/console"

  livecheck do
    url "https://apifast.qiyou.cn/api/common_bll/v1/official_web/download_url?client_type=MAC"
    regex(/vrelease[._-]?([0-9][0-9.]*)-Release/i)
    strategy :json do |json, regex|
      match = json["download_url"]&.match(regex)
      next if match.blank?

      version = match[1]
      if version.match?(/^\d+\.\d+\.\d+$/)
        version
      elsif version.match?(/^\d{3,}$/)
        "#{version[0]}.#{version[1]}.#{version[2..]}"
      end
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
