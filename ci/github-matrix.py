#!/usr/bin/env python3
"""Build GitHub Actions matrix JSON from ci/image-matrix.sh."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MATRIX_SH = ROOT / "ci" / "image-matrix.sh"


def read_rows() -> list[tuple[str, str, str, str]]:
    proc = subprocess.run(
        ["sh", str(MATRIX_SH)],
        check=True,
        capture_output=True,
        text=True,
        cwd=ROOT,
    )
    rows: list[tuple[str, str, str, str]] = []
    for line in proc.stdout.splitlines():
        parts = line.split("\t")
        if len(parts) != 4:
            continue
        rows.append((parts[0], parts[1], parts[2], parts[3]))
    return rows


def matrix_for(kind: str) -> dict[str, list[dict[str, str]]]:
    include: list[dict[str, str]] = []
    for name, context, dockerfile, base in read_rows():
        if kind == "bases" and not base:
            include.append(
                {"name": name, "context": context, "dockerfile": dockerfile}
            )
        elif kind == "images" and base:
            include.append(
                {
                    "name": name,
                    "context": context,
                    "dockerfile": dockerfile,
                    "base": base,
                }
            )
    if kind not in ("bases", "images"):
        raise SystemExit(f"unknown kind: {kind}")
    return {"include": include}


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("usage: github-matrix.py bases|images")
    print(json.dumps(matrix_for(sys.argv[1]), separators=(",", ":")))


if __name__ == "__main__":
    main()
