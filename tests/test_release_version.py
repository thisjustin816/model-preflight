"""Check that plugin manifests and release tags describe one version."""
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    'check_release_version', ROOT / 'scripts/check_release_version.py'
)
CHECKER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(CHECKER)


class ReleaseVersionTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.manifests = [Path(self.temp.name) / name for name in ('claude.json', 'codex.json')]
        for path in self.manifests:
            path.write_text(json.dumps({'version': '1.2.3'}), encoding='utf-8')

    def test_matching_manifests_and_tag(self):
        self.assertEqual(CHECKER.check_versions(self.manifests, 'v1.2.3'), '1.2.3')

    def test_mismatched_manifests_fail(self):
        self.manifests[1].write_text('{"version": "1.2.2"}', encoding='utf-8')
        with self.assertRaisesRegex(ValueError, 'different versions'):
            CHECKER.check_versions(self.manifests)

    def test_invalid_semver_fails(self):
        self.manifests[0].write_text('{"version": "01.2.3"}', encoding='utf-8')
        self.manifests[1].write_text('{"version": "01.2.3"}', encoding='utf-8')
        with self.assertRaisesRegex(ValueError, 'not a release version'):
            CHECKER.check_versions(self.manifests)

    def test_mismatched_tag_fails(self):
        with self.assertRaisesRegex(ValueError, 'does not match'):
            CHECKER.check_versions(self.manifests, 'v1.2.2')


if __name__ == '__main__':
    unittest.main()
