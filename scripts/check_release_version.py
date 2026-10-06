#!/usr/bin/env python3
"""Check that both plugin manifests and an optional release tag agree."""
import argparse
import json
import os
from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]
MANIFESTS = (
    ROOT / '.claude-plugin/plugin.json',
    ROOT / '.codex-plugin/plugin.json',
)
RELEASE_VERSION = re.compile(r'(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)')


def check_versions(manifests, tag=None):
    versions = []
    for path in manifests:
        version = json.loads(path.read_text(encoding='utf-8')).get('version')
        if not isinstance(version, str) or not RELEASE_VERSION.fullmatch(version):
            raise ValueError(f'{path}: not a release version: {version!r}')
        versions.append(version)
    if len(set(versions)) != 1:
        raise ValueError(f'plugin manifests have different versions: {versions}')
    version = versions[0]
    if tag and tag != f'v{version}':
        raise ValueError(f'tag {tag!r} does not match plugin version {version!r}')
    return version


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--tag', help='release tag to compare with both manifests')
    args = parser.parse_args()
    tag = args.tag
    if not tag and os.environ.get('GITHUB_REF_TYPE') == 'tag':
        tag = os.environ.get('GITHUB_REF_NAME')
    try:
        version = check_versions(MANIFESTS, tag)
    except (OSError, ValueError, KeyError, TypeError) as error:
        parser.exit(1, f'{error}\n')
    print(f'Model Preflight {version}')


if __name__ == '__main__':
    main()
