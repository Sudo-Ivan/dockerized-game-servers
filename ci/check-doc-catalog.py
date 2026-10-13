#!/usr/bin/env python3
"""Check that every first-party server in the catalog has a docs page."""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SERVERS_DIR = ROOT / "docs" / "servers"

# Catalog ids that share one docs page.
DOC_SLUG_BY_CATALOG_ID = {
    "fabric": "minecraft",
    "vanilla": "minecraft",
    "forge": "minecraft",
    "neoforge": "minecraft",
    "valheim-plus": "valheim",
}


def main() -> int:
    output = subprocess.run(
        [str(ROOT / "ci" / "server-catalog.sh")],
        cwd=ROOT,
        capture_output=True,
        text=True,
        check=True,
    ).stdout

    missing: list[str] = []
    first_party = 0
    for line in output.splitlines():
        parts = line.split("\t")
        if len(parts) < 7 or not parts[0].strip():
            continue
        catalog_id, first = parts[0], parts[6]
        if first != "1":
            continue
        first_party += 1
        slug = DOC_SLUG_BY_CATALOG_ID.get(catalog_id, catalog_id)
        if not (SERVERS_DIR / f"{slug}.md").is_file():
            missing.append(f"{catalog_id} -> docs/servers/{slug}.md")

    if missing:
        print("doc catalog check failed (missing server guides):", file=sys.stderr)
        for row in missing:
            print(f"  {row}", file=sys.stderr)
        return 1

    print(f"doc catalog check ok ({first_party} first-party servers)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
