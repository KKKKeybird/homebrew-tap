cask "haima-cloud" do
  version "1.1.9"
  sha256 "efc8e015ed6abaf45211758ea09598f5b07ad9e09e995a7bb4f79defe6a51b2b"

  url "https://pc-cos.haimacloud.com/release/haimayun/v#{version}/mac_arm/%E6%B5%B7%E9%A9%AC%E4%BA%91%E7%94%B5%E8%84%91-v#{version}-darwin-arm64.dmg"
  name "Haima Cloud Computer"
  name "海马云电脑"
  desc "Cloud computer and cloud gaming client"
  homepage "https://pc.haimacloud.com/"

  depends_on arch: :arm64
  depends_on macos: :big_sur

  app "海马云电脑.app"
end
