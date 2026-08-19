# release_tag: rounded-v0.0.3-d188017
# source_commit: d188017c64ef4e611781618f2499c09d5ac4599c
class InshellisenseRounded < Formula
  desc "IDE-style command-line autocomplete with rounded suggestion boxes"
  homepage "https://github.com/KKKKeybird/inshellisense/tree/agent/rounded-corners"
  version "0.0.3-rounded.d188017"
  license "MIT"

  conflicts_with "inshellisense", because: "both install inshellisense and is binaries"

  on_macos do
    on_arm do
      url "https://github.com/KKKKeybird/inshellisense/releases/download/rounded-v0.0.3-d188017/microsoft-inshellisense-darwin-arm64-0.0.3.tgz"
      sha256 "1156a0f2e986aa04fc28dc2be11f073494ec5b0fec70e786bbfaee6f12a96c93"
    end

    on_intel do
      url "https://github.com/KKKKeybird/inshellisense/releases/download/rounded-v0.0.3-d188017/microsoft-inshellisense-darwin-x64-0.0.3.tgz"
      sha256 "cb414b9d07943fb17bd11102c13dfcbed5024570f06354e2ecb80fad796b406c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/KKKKeybird/inshellisense/releases/download/rounded-v0.0.3-d188017/microsoft-inshellisense-linux-arm64-0.0.3.tgz"
      sha256 "ee19372b10cacb2e46cde0da3808bd54c5847bed15ab13f0a0d4f59b2380c050"
    end

    on_intel do
      url "https://github.com/KKKKeybird/inshellisense/releases/download/rounded-v0.0.3-d188017/microsoft-inshellisense-linux-x64-0.0.3.tgz"
      sha256 "c5e96592d39510f8dfee921e1e336695194b9a20a8f5d94b257046c4b8f66e68"
    end
  end

  def install
    binary = Dir["inshellisense-*"].fetch(0)
    bin.install binary => "inshellisense"
    bin.install_symlink "inshellisense" => "is"
  end

  test do
    system bin/"inshellisense", "--version"
  end
end
