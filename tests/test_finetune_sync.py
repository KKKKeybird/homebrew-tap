import importlib.util
import io
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
import zipfile

spec = importlib.util.spec_from_file_location(
    "sync", Path(__file__).resolve().parents[1] / ".github/scripts/sync-finetune.py")
sync = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sync)


class FineTuneSyncTests(unittest.TestCase):
    def artifact(self, **overrides):
        return dict(name="FineTune-1.9.1-hwong103", expired=False,
                    digest="sha256:" + "a" * 64, **overrides)

    def test_expired_ambiguous_and_unsigned_artifacts_fail_closed(self):
        for artifacts in ([dict(self.artifact(), expired=True)], [],
                          [self.artifact(), self.artifact()],
                          [dict(self.artifact(), digest=None)]):
            with self.subTest(artifacts=artifacts), self.assertRaises(ValueError):
                sync.select_artifact(artifacts)

    def test_selects_named_installer_not_logs(self):
        app = self.artifact()
        self.assertEqual(sync.select_artifact([app, {"name": "logs"}]), app)

    def test_ignores_pull_request_builds(self):
        run = dict(id=123, head_branch="main", conclusion="success", event="push",
                   path=".github/workflows/build-app.yml")
        with patch.object(sync, "api", return_value={"workflow_runs": [dict(run, event="pull_request"), run]}):
            self.assertEqual(sync.latest_run(), run)

    def test_unwraps_inner_zip_byte_for_byte(self):
        self.check_zip({"FineTune.app/Contents/Info.plist": b"plist"})

    def test_rejects_traversal_and_unexpected_bundle(self):
        for name in ("../outside", "/outside", "Other.app/Contents/Info.plist"):
            with self.subTest(name=name), self.assertRaises(ValueError):
                self.check_zip({name: b"bad"})

    def test_symlinks_must_stay_inside_bundle(self):
        for target in ("../../../outside", "/tmp/outside"):
            with self.subTest(target=target), self.assertRaises(ValueError):
                self.check_zip({"FineTune.app/Contents/Info.plist": b"plist"}, target)
        self.check_zip({"FineTune.app/Contents/Info.plist": b"plist"}, "Versions/Current")

    def check_zip(self, files, symlink=None):
        inner = io.BytesIO()
        with zipfile.ZipFile(inner, "w") as archive:
            for name, value in files.items():
                archive.writestr(name, value)
            if symlink:
                info = zipfile.ZipInfo("FineTune.app/Contents/link")
                info.create_system = 3
                info.external_attr = 0o120777 << 16
                archive.writestr(info, symlink)
        payload = inner.getvalue()
        with tempfile.TemporaryDirectory() as temp:
            outer, target = Path(temp) / "artifact.zip", Path(temp) / "installer.zip"
            with zipfile.ZipFile(outer, "w") as archive:
                archive.writestr("FineTune-1.9.1-hwong103.zip", payload)
            sync.unpack_artifact(outer, target)
            self.assertEqual(target.read_bytes(), payload)

    def test_build_and_rerun_identity_change_cask_version_and_url(self):
        args = ["KKKKeybird/homebrew-tap", "1.9.1", 123, 1, "a" * 64, "15.4", {"arm64"}]
        first = sync.render_cask(*args)
        self.assertIn('version "1.9.1,123.1"', first)
        self.assertIn('depends_on arch: :arm64', first)
        self.assertIn('depends_on macos: ">= :sequoia"', first)
        self.assertIn('requires macOS 15.4 or later', first)
        args[3] = 2
        rerun = sync.render_cask(*args)
        self.assertIn('version "1.9.1,123.2"', rerun)
        self.assertNotEqual(first, rerun)
        args[-1] = {"arm64", "x86_64"}
        self.assertNotIn("depends_on arch:", sync.render_cask(*args))


if __name__ == "__main__":
    unittest.main()
