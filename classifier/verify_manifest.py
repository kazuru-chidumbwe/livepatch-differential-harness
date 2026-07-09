#!/usr/bin/env python3
"""Verify artifact-manifest.json completeness."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

REQUIRED_CELL_KEYS = {
    "patch_id",
    "tool_id",
    "channel_1",
    "channel_2",
    "channel_3",
    "cell_outcome",
}


def verify_manifest(path: Path) -> int:
    data = json.loads(path.read_text(encoding="utf-8"))
    if data.get("manifest_version") != 1:
        print("FAIL: manifest_version != 1", file=sys.stderr)
        return 1
    cells = data.get("cells", [])
    if not cells:
        print("FAIL: no cells", file=sys.stderr)
        return 1
    for i, cell in enumerate(cells):
        missing = REQUIRED_CELL_KEYS - set(cell)
        if missing:
            print(f"FAIL: cell {i} missing {missing}", file=sys.stderr)
            return 1
    print(f"OK: {len(cells)} cells verified")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("manifest", type=Path)
    args = parser.parse_args()
    return verify_manifest(args.manifest)


if __name__ == "__main__":
    sys.exit(main())
