import { createHash } from "node:crypto";
import { mkdir, readdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";

const { PACKAGE_DIR, RELEASE_TAG, SOURCE_SHA, VERSION } = process.env;
if (!PACKAGE_DIR || !RELEASE_TAG || !SOURCE_SHA || !VERSION) {
  throw new Error(
    "PACKAGE_DIR, RELEASE_TAG, SOURCE_SHA, and VERSION are required",
  );
}

const platforms = ["darwin-arm64", "darwin-x64", "linux-arm64", "linux-x64"];
const files = await readdir(PACKAGE_DIR);
const packages = {};

for (const platform of platforms) {
  const filename = files.find(
    (file) => file === `microsoft-inshellisense-${platform}-${VERSION}.tgz`,
  );
  if (!filename) throw new Error(`missing package for ${platform}`);

  const archive = await readFile(path.join(PACKAGE_DIR, filename));
  packages[platform] = {
    filename,
    sha256: createHash("sha256").update(archive).digest("hex"),
  };
}

const releaseUrl = (platform) =>
  `https://github.com/KKKKeybird/inshellisense/releases/download/${RELEASE_TAG}/${packages[platform].filename}`;

const formula = `# release_tag: ${RELEASE_TAG}
# source_commit: ${SOURCE_SHA}
class InshellisenseRounded < Formula
  desc "IDE-style command-line autocomplete with rounded suggestion boxes"
  homepage "https://github.com/KKKKeybird/inshellisense/tree/agent/rounded-corners"
  version "${VERSION}-rounded.${SOURCE_SHA.slice(0, 7)}"
  license "MIT"

  conflicts_with "inshellisense", because: "both install inshellisense and is binaries"

  on_macos do
    on_arm do
      url "${releaseUrl("darwin-arm64")}"
      sha256 "${packages["darwin-arm64"].sha256}"
    end

    on_intel do
      url "${releaseUrl("darwin-x64")}"
      sha256 "${packages["darwin-x64"].sha256}"
    end
  end

  on_linux do
    on_arm do
      url "${releaseUrl("linux-arm64")}"
      sha256 "${packages["linux-arm64"].sha256}"
    end

    on_intel do
      url "${releaseUrl("linux-x64")}"
      sha256 "${packages["linux-x64"].sha256}"
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
`;

await mkdir("Formula", { recursive: true });
await writeFile("Formula/inshellisense-rounded.rb", formula);
