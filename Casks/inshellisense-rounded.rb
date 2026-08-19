# release_tag: rounded-v0.0.3-d188017
# source_commit: d188017c64ef4e611781618f2499c09d5ac4599c
cask "inshellisense-rounded" do
  arch arm: "arm64", intel: "x64"

  version "0.0.3,d188017"
  sha256 arm:   "1156a0f2e986aa04fc28dc2be11f073494ec5b0fec70e786bbfaee6f12a96c93",
         intel: "cb414b9d07943fb17bd11102c13dfcbed5024570f06354e2ecb80fad796b406c"

  url "https://github.com/KKKKeybird/inshellisense/releases/download/rounded-v#{version.csv.first}-#{version.csv.second}/microsoft-inshellisense-darwin-#{arch}-#{version.csv.first}.tgz"
  name "inshellisense Rounded"
  desc "IDE-style command-line autocomplete with rounded suggestion boxes"
  homepage "https://github.com/KKKKeybird/inshellisense/tree/agent/rounded-corners"

  depends_on :macos

  binary "package/inshellisense-darwin-#{arch}", target: "inshellisense"
  binary "package/inshellisense-darwin-#{arch}", target: "is"

  caveats "Run is reinit after installing or upgrading the cask."
end
