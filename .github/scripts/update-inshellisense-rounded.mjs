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

const cask = `# release_tag: ${RELEASE_TAG}
# source_commit: ${SOURCE_SHA}
cask "inshellisense-rounded" do
  arch arm: "arm64", intel: "x64"

  version "${VERSION}-rounded.${SOURCE_SHA.slice(0, 7)}"
  sha256 arm:   "${packages["darwin-arm64"].sha256}",
         intel: "${packages["darwin-x64"].sha256}"

  url "https://github.com/KKKKeybird/inshellisense/releases/download/${RELEASE_TAG}/microsoft-inshellisense-darwin-#{arch}-${VERSION}.tgz"
  name "inshellisense Rounded"
  desc "IDE-style command-line autocomplete with rounded suggestion boxes"
  homepage "https://github.com/KKKKeybird/inshellisense/tree/agent/rounded-corners"

  depends_on :macos

  binary "package/inshellisense-darwin-#{arch}", target: "inshellisense"
  binary "package/inshellisense-darwin-#{arch}", target: "is"

  caveats "Run is reinit after installing or upgrading the cask."
end
`;

await mkdir("Casks", { recursive: true });
await writeFile("Casks/inshellisense-rounded.rb", cask);
