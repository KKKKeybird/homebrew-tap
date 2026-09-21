cask "haima-cloud" do
  version "2.7.4"
  sha256 "90bda0e7d30cd0c8c21265864923ddae696907bd3ad83547ad7f33fa342b5134"

  url "https://pc-cos.haimacloud.com/release/haimayun/v#{version}/mac_arm/%E6%B5%B7%E9%A9%AC%E4%BA%91%E7%94%B5%E8%84%91-v#{version}-darwin-arm64.dmg",
      user_agent: :browser
  name "Haima Cloud Computer"
  name "海马云电脑"
  desc "Cloud computer and cloud gaming client"
  homepage "https://pc.haimacloud.com/"

  livecheck do
    skip "Upstream release API requires a POST request"
  end

  depends_on arch: :arm64
  depends_on macos: :big_sur

  app "海马云电脑.app"
end
