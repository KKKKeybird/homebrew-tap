#!/usr/bin/env python3
"""Mirror FineTune's latest successful GitHub prerelease into this tap."""

import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import plistlib
import re
import subprocess
import tempfile
import zipfile

UPSTREAM = "KKKKeybird/FineTune"
CASK = Path("Casks/finetune-nightly.rb")
STATE = Path(".github/finetune-nightly.json")
VERSION_RE = re.compile(
    r"^1\.9\.1-nightly\.[0-9]{8}\.(?:[0-9]+|[0-9a-f]{12})$"
)
RELEASE_TAG_RE = re.compile(r"^nightly-[0-9]{8}-(?:[0-9]+|[0-9a-f]{12})$")
ASSET_RE = re.compile(
    r"^FineTune-Nightly-(?P<version>"
    r"1\.9\.1-nightly\.[0-9]{8}\.(?:[0-9]+|[0-9a-f]{12}))\.zip$"
)


def command(*args):
    return subprocess.check_output(args, text=True).strip()


def api(endpoint):
    return json.loads(command("gh", "api", endpoint))


def select_release(releases):
    candidates = []
    for release in releases:
        tag = release.get("tag_name", "")
        if (not release.get("draft") and release.get("prerelease")
                and RELEASE_TAG_RE.fullmatch(tag)):
            candidates.append(release)
    if not candidates:
        raise ValueError("No FineTune Nightly prerelease found")
    return max(candidates, key=lambda release: (release["created_at"], release["id"]))


def select_assets(release):
    zips = [asset for asset in release.get("assets", [])
            if ASSET_RE.fullmatch(asset.get("name", ""))]
    sums = [asset for asset in release.get("assets", [])
            if asset.get("name", "").endswith(".sha256")
            and asset.get("name") == zips[0]["name"].removesuffix(".zip") + ".sha256"] if len(zips) == 1 else []
    if len(zips) != 1 or len(sums) != 1:
        raise ValueError("Nightly release must contain exactly one ZIP and its SHA-256 sidecar")
    installer, checksum = zips[0], sums[0]
    if installer.get("state") != "uploaded" or checksum.get("state") != "uploaded":
        raise ValueError("Nightly release assets are not fully uploaded")
    version = installer["name"].removeprefix("FineTune-Nightly-").removesuffix(".zip")
    if not VERSION_RE.fullmatch(version):
        raise ValueError("Unexpected FineTune Nightly version")
    return installer, checksum, version


def sha256(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def download_asset(asset, target):
    with target.open("wb") as stream:
        subprocess.run(
            ["gh", "api", "-H", "Accept: application/octet-stream",
             f"repos/{UPSTREAM}/releases/assets/{asset['id']}"],
            stdout=stream,
            check=True,
        )


def tap_release_exists(tap_repository, tap_tag):
    result = subprocess.run(
        ["gh", "release", "view", tap_tag, "-R", tap_repository,
         "--json", "assets"],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    return result.returncode == 0


def validate_archive(installer, version):
    with zipfile.ZipFile(installer) as archive:
        names = set(archive.namelist())
        for item in archive.infolist():
            path = PurePosixPath(item.filename)
            if (path.is_absolute() or ".." in path.parts or "\\" in item.filename
                    or not path.parts
                    or path.parts[0] not in {"FineTune Nightly.app", "__MACOSX"}):
                raise ValueError("Unsafe or unexpected Nightly app archive path")
        if "FineTune Nightly.app/Contents/Info.plist" not in names:
            raise ValueError("Missing FineTune Nightly Info.plist")
        bad = archive.testzip()
        if bad:
            raise ValueError(f"Corrupt ZIP member: {bad}")


def inspect_app(work, version):
    command("ditto", "-x", "-k", str(work / "FineTune-Nightly.zip"), str(work / "unpacked"))
    app = work / "unpacked/FineTune Nightly.app"
    command("codesign", "--verify", "--deep", "--strict", str(app))
    with (app / "Contents/Info.plist").open("rb") as stream:
        info = plistlib.load(stream)
    if info.get("CFBundleIdentifier") != "io.github.kkkkeybird.FineTune.nightly":
        raise ValueError("Unexpected Nightly bundle identifier")
    if info.get("CFBundleShortVersionString") != version:
        raise ValueError("Nightly asset name and app version disagree")
    executable = info.get("CFBundleExecutable")
    if not executable or Path(executable).name != executable:
        raise ValueError("Unexpected Nightly bundle executable path")
    arches = set(command("lipo", "-archs", str(app / "Contents/MacOS" / executable)).split())
    if not arches or not arches <= {"arm64", "x86_64"}:
        raise ValueError("Unsupported Nightly Mach-O architectures")
    minimum = info.get("LSMinimumSystemVersion")
    if minimum != "15.4":
        raise ValueError(f"Unexpected minimum macOS version: {minimum}")
    return minimum, arches


def render_cask(tap_repository, tap_tag, version, digest, minimum, arches):
    if not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", tap_repository):
        raise ValueError("Invalid tap repository")
    if not re.fullmatch(r"finetune-nightly-#\{version\}-[0-9]+", tap_tag):
        raise ValueError("Invalid tap release tag")
    if not VERSION_RE.fullmatch(version) or not re.fullmatch(r"[0-9a-f]{64}", digest):
        raise ValueError("Invalid version or SHA-256")
    if not arches or not arches <= {"arm64", "x86_64"}:
        raise ValueError("Unsupported architectures")
    arch_line = ""
    if len(arches) == 1:
        arch_line = f"  depends_on arch: :{'arm64' if 'arm64' in arches else 'x86_64'}\n"
    return f'''cask "finetune-nightly" do
  version "{version}"
  sha256 "{digest}"

  url "https://github.com/{tap_repository}/releases/download/{tap_tag}/FineTune-Nightly.zip"
  name "FineTune Nightly"
  desc "Per-app volume control, audio routing and EQ (community nightly)"
  homepage "https://github.com/{UPSTREAM}"

  livecheck do
    skip "Version checks are handled by the FineTune Nightly sync workflow."
  end

{arch_line}  depends_on macos: :sequoia

  app "FineTune Nightly.app"

  caveats <<~EOS
    This build requires macOS {minimum} or later.
    This community nightly is ad-hoc signed and is not notarized by Apple.
    Allow it in System Settings > Privacy & Security if macOS blocks first launch.
    Grant audio capture, microphone and Bluetooth access when prompted as needed.
    Updates are managed by Homebrew; run brew upgrade --cask finetune-nightly.
    In-app Sparkle updates are disabled to prevent channel crossover.
  EOS
end
'''


def main():
    tap_repository = os.environ["GITHUB_REPOSITORY"]
    release = select_release(api(f"repos/{UPSTREAM}/releases?per_page=100"))
    installer_asset, checksum_asset, version = select_assets(release)
    previous = json.loads(STATE.read_text()) if STATE.exists() else {}
    tap_tag = f"finetune-nightly-{version}-{release['id']}"
    if (previous.get("release_id") == release["id"] and CASK.exists()
            and tap_release_exists(tap_repository, tap_tag)):
        print("FineTune Nightly is current; nothing to publish.")
        return

    with tempfile.TemporaryDirectory() as temp:
        work = Path(temp)
        installer, checksum = work / "FineTune-Nightly.zip", work / "FineTune-Nightly.sha256"
        download_asset(installer_asset, installer)
        download_asset(checksum_asset, checksum)
        digest = sha256(installer)
        declared = checksum.read_text().split()
        if len(declared) < 2 or declared[0] != digest:
            raise ValueError("Downloaded ZIP does not match its SHA-256 sidecar")
        if installer_asset.get("digest") != f"sha256:{digest}":
            raise ValueError("Downloaded ZIP does not match GitHub's asset digest")

        validate_archive(installer, version)
        minimum, arches = inspect_app(work, version)

        tap_tag_template = f"finetune-nightly-#{{version}}-{release['id']}"
        cask = render_cask(tap_repository, tap_tag_template, version, digest, minimum, arches)
        CASK.parent.mkdir(exist_ok=True)
        CASK.write_text(cask)
        command("ruby", "-c", str(CASK))

        provenance = {
            "upstream": UPSTREAM,
            "release_id": release["id"],
            "release_tag": release["tag_name"],
            "release_url": release["html_url"],
            "tap_tag": tap_tag,
            "version": version,
            "source_sha256": digest,
            "minimum_macos": minimum,
            "architectures": sorted(arches),
        }
        STATE.write_text(json.dumps(provenance, indent=2) + "\n")

        output = Path(os.environ["RUNNER_TEMP"]) / "finetune-nightly-release"
        output.mkdir(exist_ok=True)
        (output / "FineTune-Nightly.zip").write_bytes(installer.read_bytes())
        (output / "provenance.json").write_text(STATE.read_text())
        (output / "SHA256SUMS").write_text(f"{digest}  FineTune-Nightly.zip\n")
        with open(os.environ["GITHUB_OUTPUT"], "a") as stream:
            stream.write(f"changed=true\ntag={tap_tag}\n")
        print(json.dumps(provenance, indent=2))


if __name__ == "__main__":
    main()
