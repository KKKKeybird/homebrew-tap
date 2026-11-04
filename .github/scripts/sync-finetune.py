#!/usr/bin/env python3
"""Mirror hwong103's latest successful main build without rebuilding its app."""

import hashlib
import json
import os
from pathlib import Path, PurePosixPath
import plistlib
import re
import stat
import subprocess
import tempfile
import zipfile

UPSTREAM = "hwong103/FineTune"
WORKFLOW = "build-app.yml"
CASK = Path("Casks/finetune-hwong.rb")
STATE = Path(".github/finetune-hwong.json")


def command(*args):
    return subprocess.check_output(args, text=True).strip()


def api(endpoint):
    return json.loads(command("gh", "api", endpoint))


def latest_run():
    # Query the build workflow, never CI or the upstream-sync workflow.
    page = 1
    while True:
        runs = api(f"repos/{UPSTREAM}/actions/workflows/{WORKFLOW}/runs"
                   f"?branch=main&status=success&per_page=100&page={page}")["workflow_runs"]
        for run in runs:
            if (run["head_branch"] == "main" and run["conclusion"] == "success"
                    and run["event"] in {"push", "workflow_dispatch"}
                    and run["path"] == f".github/workflows/{WORKFLOW}"):
                return run
        if len(runs) < 100:
            raise ValueError("No successful main Build App run found")
        page += 1


def select_artifact(artifacts):
    matches = [a for a in artifacts if re.fullmatch(r"FineTune-[0-9]+(?:\.[0-9]+)*-hwong103", a["name"])]
    if len(matches) != 1 or matches[0]["expired"]:
        raise ValueError("Latest build must have exactly one unexpired FineTune artifact")
    artifact = matches[0]
    if not re.fullmatch(r"sha256:[0-9a-f]{64}", artifact.get("digest") or ""):
        raise ValueError("Artifact has no usable GitHub SHA-256 digest")
    return artifact


def sha256(path):
    with path.open("rb") as stream:
        return hashlib.file_digest(stream, "sha256").hexdigest()


def unpack_artifact(outer, target):
    # upload-artifact wraps the actual installer ZIP in another ZIP. Mirror the
    # inner ZIP byte-for-byte, including Apple's resource forks and signature.
    with zipfile.ZipFile(outer) as archive:
        files = [i for i in archive.infolist() if not i.is_dir()]
        if len(files) != 1 or not re.fullmatch(r"FineTune-[0-9.]+-hwong103\.zip", files[0].filename):
            raise ValueError("Unexpected artifact wrapper contents")
        target.write_bytes(archive.read(files[0]))
    with zipfile.ZipFile(target) as archive:
        names = set(archive.namelist())
        for item in archive.infolist():
            path = PurePosixPath(item.filename)
            if (path.is_absolute() or ".." in path.parts or "\\" in item.filename
                    or not path.parts or path.parts[0] not in {"FineTune.app", "__MACOSX"}):
                raise ValueError("Unsafe or unexpected app archive path")
            if stat.S_ISLNK(item.external_attr >> 16):
                link = archive.read(item).decode("utf-8")
                resolved = os.path.normpath(str(path.parent / link))
                if not resolved.startswith(path.parts[0] + "/"):
                    raise ValueError("App archive contains an escaping symlink")
        if "FineTune.app/Contents/Info.plist" not in names:
            raise ValueError("Missing FineTune.app Info.plist")
        bad = archive.testzip()
        if bad:
            raise ValueError(f"Corrupt ZIP member: {bad}")


def render_cask(repository, version, run_id, attempt, digest, minimum, arches):
    if not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", repository):
        raise ValueError("Invalid destination repository")
    if not re.fullmatch(r"[0-9]+(?:\.[0-9]+)*", version) or not re.fullmatch(r"[0-9]+(?:\.[0-9]+)*", minimum):
        raise ValueError("Invalid app version or minimum macOS version")
    if not re.fullmatch(r"[0-9a-f]{64}", digest) or run_id < 1 or attempt < 1:
        raise ValueError("Invalid build identity or SHA-256")
    if not arches or not arches <= {"arm64", "x86_64"}:
        raise ValueError("Unsupported Mach-O architectures")
    arch_line = ""
    if len(arches) == 1:
        arch_line = f"  depends_on arch: :{'arm64' if 'arm64' in arches else 'x86_64'}\n"
    tag = f"finetune-hwong-{version}-{run_id}-{attempt}"
    return f'''cask "finetune-hwong" do
  version "{version},{run_id}.{attempt}"
  sha256 "{digest}"

  url "https://github.com/{repository}/releases/download/{tag}/FineTune-hwong.zip",
      verified: "github.com/{repository}/"
  name "FineTune (hwong103)"
  desc "Per-app volume control, audio routing and EQ (hwong103 fork)"
  homepage "https://github.com/{UPSTREAM}"

  conflicts_with cask: "finetune"
{arch_line}  depends_on macos: ">= {minimum}"

  app "FineTune.app"

  caveats <<~EOS
    This upstream community build is ad-hoc signed and is not notarized by Apple.
    Allow it in System Settings > Privacy & Security if macOS blocks first launch.
    Grant audio capture, microphone and Bluetooth access when prompted as needed.
    Updates are delivered by this tap; run brew upgrade --cask finetune-hwong.
  EOS
end
'''


def main():
    repository = os.environ["GITHUB_REPOSITORY"]
    run = latest_run()
    run_id, attempt = int(run["id"]), int(run["run_attempt"])
    previous = json.loads(STATE.read_text()) if STATE.exists() else {}
    identity = (run_id, attempt)
    old_identity = (previous.get("run_id", 0), previous.get("run_attempt", 0))
    if identity <= old_identity and CASK.exists():
        print("FineTune is current; nothing to download or publish.")
        return
    artifact = select_artifact(api(f"repos/{UPSTREAM}/actions/runs/{run_id}/artifacts")["artifacts"])
    with tempfile.TemporaryDirectory() as temp:
        work = Path(temp)
        outer, installer = work / "artifact.zip", work / "FineTune-hwong.zip"
        with outer.open("wb") as stream:
            subprocess.run(["gh", "api", f"repos/{UPSTREAM}/actions/artifacts/{artifact['id']}/zip"],
                           stdout=stream, check=True)
        if "sha256:" + sha256(outer) != artifact["digest"]:
            raise ValueError("Downloaded artifact does not match GitHub's digest")
        unpack_artifact(outer, installer)
        command("ditto", "-x", "-k", str(installer), str(work / "unpacked"))
        app = work / "unpacked/FineTune.app"
        command("codesign", "--verify", "--deep", "--strict", str(app))
        with (app / "Contents/Info.plist").open("rb") as stream:
            info = plistlib.load(stream)
        if info["CFBundleIdentifier"] != "com.finetuneapp.FineTune":
            raise ValueError("Unexpected bundle identifier")
        executable = info["CFBundleExecutable"]
        if Path(executable).name != executable:
            raise ValueError("Unexpected bundle executable path")
        arches = set(command("lipo", "-archs", str(app / "Contents/MacOS" / executable)).split())
        version, minimum = info["CFBundleShortVersionString"], info["LSMinimumSystemVersion"]
        if artifact["name"] != f"FineTune-{version}-hwong103":
            raise ValueError("Artifact name and app version disagree")
        digest = sha256(installer)
        cask = render_cask(repository, version, run_id, attempt, digest, minimum, arches)
        # Validate before publishing. The workflow runs Homebrew checks next.
        CASK.parent.mkdir(exist_ok=True)
        CASK.write_text(cask)
        command("ruby", "-c", str(CASK))
        provenance = {
            "upstream": UPSTREAM, "workflow": WORKFLOW, "run_id": run_id,
            "run_attempt": attempt, "commit": run["head_sha"],
            "run_url": run["html_url"], "artifact_id": artifact["id"],
            "artifact_digest": artifact["digest"], "version": version,
            "sha256": digest, "minimum_macos": minimum, "architectures": sorted(arches),
        }
        STATE.write_text(json.dumps(provenance, indent=2) + "\n")
        # Keep staged files in RUNNER_TEMP so subsequent steps can validate and
        # publish; never place a temporary artifact in the Git checkout.
        output = Path(os.environ["RUNNER_TEMP"]) / "finetune-release"
        output.mkdir(exist_ok=True)
        (output / installer.name).write_bytes(installer.read_bytes())
        (output / "provenance.json").write_text(STATE.read_text())
        (output / "SHA256SUMS").write_text(f"{digest}  {installer.name}\n")
        with open(os.environ["GITHUB_OUTPUT"], "a") as stream:
            stream.write(f"changed=true\ntag=finetune-hwong-{version}-{run_id}-{attempt}\n")
        print(json.dumps(provenance, indent=2))


if __name__ == "__main__":
    main()
