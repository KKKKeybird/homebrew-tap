# release_tag: rounded-v0.0.3-6cfeddd
# source_commit: 6cfeddd17d7d4b4242d9a31b441102961f723a61
class InshellisenseRounded < Formula
  desc "IDE-style command-line autocomplete with rounded suggestion boxes"
  homepage "https://github.com/KKKKeybird/inshellisense/tree/agent/rounded-corners"
  version "0.0.3-rounded.6cfeddd"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/KKKKeybird/inshellisense/releases/download/rounded-v0.0.3-6cfeddd/microsoft-inshellisense-darwin-arm64-0.0.3.tgz"
      sha256 "1156a0f2e986aa04fc28dc2be11f073494ec5b0fec70e786bbfaee6f12a96c93"
    end

    on_intel do
      url "https://github.com/KKKKeybird/inshellisense/releases/download/rounded-v0.0.3-6cfeddd/microsoft-inshellisense-darwin-x64-0.0.3.tgz"
      sha256 "cb414b9d07943fb17bd11102c13dfcbed5024570f06354e2ecb80fad796b406c"
    end
  end

  bottle do
    root_url "https://github.com/KKKKeybird/inshellisense/releases/download/rounded-v0.0.3-6cfeddd"
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "48fecbd768ab4ba97101cfad83c02920b0e16058164ff908d0754d56e0a69e07"
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
