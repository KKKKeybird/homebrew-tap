# release_tag: rounded-v0.0.3-70d5605
# source_commit: 70d5605f722d49a3a35695a94d9181c5fe0df655
class InshellisenseRounded < Formula
  desc "IDE-style command-line autocomplete with rounded suggestion boxes"
  homepage "https://github.com/KKKKeybird/inshellisense/tree/agent/rounded-corners"
  version "0.0.3-rounded.70d5605"
  license "MIT"

  bottle do
    root_url "https://github.com/KKKKeybird/inshellisense/releases/download/rounded-v0.0.3-70d5605"
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "8584eb649ab10ed9c00fda9e170506876cd16822d2eba703fd96cad8ef5051ad"
  end

  on_macos do
    on_arm do
      url "https://github.com/KKKKeybird/inshellisense/releases/download/rounded-v0.0.3-70d5605/microsoft-inshellisense-darwin-arm64-0.0.3.tgz"
      sha256 "1156a0f2e986aa04fc28dc2be11f073494ec5b0fec70e786bbfaee6f12a96c93"
    end

    on_intel do
      url "https://github.com/KKKKeybird/inshellisense/releases/download/rounded-v0.0.3-70d5605/microsoft-inshellisense-darwin-x64-0.0.3.tgz"
      sha256 "cb414b9d07943fb17bd11102c13dfcbed5024570f06354e2ecb80fad796b406c"
    end
  end

  conflicts_with "inshellisense", because: "both install inshellisense and is binaries"

  def install
    binary = Dir["inshellisense-*"].fetch(0)
    bin.install binary => "inshellisense"
    bin.install_symlink "inshellisense" => "is"
  end

  test do
    system bin/"inshellisense", "--version"
  end
end
