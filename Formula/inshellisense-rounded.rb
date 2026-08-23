# release_tag: rounded-v0.0.3
# source_commit: 3cc700bd7597ba2418d5ff52d0d9d8aadf4ca6c3
class InshellisenseRounded < Formula
  desc "IDE-style command-line autocomplete with rounded suggestion boxes"
  homepage "https://github.com/KKKKeybird/inshellisense/tree/agent/rounded-corners"
  version "0.0.3-rounded.3cc700b"
  license "MIT"

  bottle do
    root_url "https://github.com/KKKKeybird/inshellisense/releases/download/rounded-v0.0.3"
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "08391a9f9560638c5ad9600a9a2c610179fa73640e285ac25a5191c06e1c216e"
  end

  on_macos do
    on_arm do
      url "https://github.com/KKKKeybird/inshellisense/releases/download/rounded-v0.0.3/microsoft-inshellisense-darwin-arm64-0.0.3.tgz"
      sha256 "9aa7ed6ebfe57b6d90015c83f17d1b261f8c3d6e5d5a4c32d19513903816d779"
    end

    on_intel do
      url "https://github.com/KKKKeybird/inshellisense/releases/download/rounded-v0.0.3/microsoft-inshellisense-darwin-x64-0.0.3.tgz"
      sha256 "d12e694d77e41734edf4525eef8fda40e1332478616e190db9cfd7f5cb42c37e"
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
