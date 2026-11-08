import importlib.util
from pathlib import Path
import unittest
from unittest.mock import Mock, patch

spec = importlib.util.spec_from_file_location(
    "nightly_sync",
    Path(__file__).resolve().parents[1] / ".github/scripts/sync-finetune-nightly.py",
)
sync = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sync)


class FineTuneNightlySyncTests(unittest.TestCase):
    def release(self, **overrides):
        version = "1.9.1-nightly.20261108.d3a5f10c9c34"
        release = dict(
            id=42,
            tag_name="nightly-20261108-d3a5f10c9c34",
            prerelease=True,
            draft=False,
            created_at="2026-11-07T08:00:00Z",
            assets=[
                dict(id=1, name=f"FineTune-Nightly-{version}.zip", state="uploaded"),
                dict(id=2, name=f"FineTune-Nightly-{version}.sha256", state="uploaded"),
            ],
        )
        release.update(overrides)
        return release

    def test_selects_latest_non_draft_prerelease(self):
        older = self.release(id=1, created_at="2026-11-06T08:00:00Z")
        latest = self.release(id=2)
        self.assertEqual(sync.select_release([older, latest]), latest)

    def test_accepts_legacy_run_number_release(self):
        legacy_version = "1.9.1-nightly.20261107.1"
        legacy = self.release(
            id=1,
            tag_name="nightly-20261107-1",
            assets=[
                dict(id=1, name=f"FineTune-Nightly-{legacy_version}.zip", state="uploaded"),
                dict(id=2, name=f"FineTune-Nightly-{legacy_version}.sha256", state="uploaded"),
            ],
        )
        self.assertEqual(sync.select_assets(legacy)[2], legacy_version)

    def test_ignores_stable_and_draft_releases(self):
        with self.assertRaises(ValueError):
            sync.select_release([
                self.release(prerelease=False),
                self.release(draft=True),
            ])

    def test_requires_one_complete_zip_and_checksum_pair(self):
        self.assertEqual(sync.select_assets(self.release())[2],
                         "1.9.1-nightly.20261108.d3a5f10c9c34")
        for assets in (
            self.release()["assets"][:1],
            self.release()["assets"] * 2,
            [dict(self.release()["assets"][0], state="new"),
             self.release()["assets"][1]],
        ):
            with self.subTest(assets=assets), self.assertRaises(ValueError):
                sync.select_assets(self.release(assets=assets))

    def test_render_cask_has_version_url_conflicts_and_brew_update(self):
        cask = sync.render_cask(
            "KKKKeybird/homebrew-tap",
            "finetune-nightly-#{version}-42",
            "1.9.1-nightly.20261108.d3a5f10c9c34",
            "a" * 64,
            "15.4",
            {"arm64", "x86_64"},
        )
        self.assertIn('version "1.9.1-nightly.20261108.d3a5f10c9c34"', cask)
        self.assertIn(
            "releases/download/finetune-nightly-#{version}-42/FineTune-Nightly.zip",
            cask,
        )
        self.assertNotIn("conflicts_with cask:", cask)
        self.assertIn("brew upgrade --cask finetune-nightly", cask)
        self.assertNotIn("depends_on arch:", cask)

    def test_tap_release_presence_is_verified_not_assumed(self):
        with patch.object(sync.subprocess, "run", return_value=Mock(returncode=1)) as run:
            self.assertFalse(sync.tap_release_exists(
                "KKKKeybird/homebrew-tap", "finetune-nightly-42"))
        with patch.object(sync.subprocess, "run", return_value=Mock(returncode=0)):
            self.assertTrue(sync.tap_release_exists(
                "KKKKeybird/homebrew-tap", "finetune-nightly-42"))


if __name__ == "__main__":
    unittest.main()
