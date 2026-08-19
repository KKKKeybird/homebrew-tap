import { createHash } from "node:crypto";
import { mkdir, readdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";

const { PACKAGE_DIR, RELEASE_TAG, SOURCE_SHA, VERSION } = process.env;
if (!PACKAGE_DIR || !RELEASE_TAG || !SOURCE_SHA || !VERSION) {
  throw new Error(
    "PACKAGE_DIR, RELEASE_TAG, SOURCE_SHA, and VERSION are required",
  );
}

const platforms = ["darwin-arm64", "darwin-x64"];
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

const bottleFilename = files.find((file) =>
  file.endsWith(".arm64_tahoe.bottle.tar.gz"),
);
if (!bottleFilename) throw new Error("missing arm64_tahoe Homebrew bottle");

const bottleArchive = await readFile(path.join(PACKAGE_DIR, bottleFilename));
const bottleSha256 = createHash("sha256").update(bottleArchive).digest("hex");
const releaseRoot = `https://github.com/KKKKeybird/inshellisense/releases/download/${RELEASE_TAG}`;
const formulaVersion = `${VERSION}-rounded.${SOURCE_SHA.slice(0, 7)}`;

const formula = `# release_tag: ${RELEASE_TAG}
# source_commit: ${SOURCE_SHA}
class InshellisenseRounded < Formula
  desc "IDE-style command-line autocomplete with rounded suggestion boxes"
  homepage "https://github.com/KKKKeybird/inshellisense/tree/agent/rounded-corners"
  version "${formulaVersion}"
  license "MIT"

  on_macos do
    on_arm do
      url "${releaseRoot}/${packages["darwin-arm64"].filename}"
      sha256 "${packages["darwin-arm64"].sha256}"
    end

    on_intel do
      url "${releaseRoot}/${packages["darwin-x64"].filename}"
      sha256 "${packages["darwin-x64"].sha256}"
    end
  end

  bottle do
    root_url "${releaseRoot}"
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "${bottleSha256}"
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
`;

await mkdir("Formula", { recursive: true });
await writeFile("Formula/inshellisense-rounded.rb", formula);
