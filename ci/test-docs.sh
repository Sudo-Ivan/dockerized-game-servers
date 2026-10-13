#!/bin/sh
# Build the docs site and run the doc catalog check.
#
# Needs zensical on PATH. See the Docs section in README.md for setup.

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "${ROOT}"

if ! command -v zensical >/dev/null 2>&1; then
  echo "zensical not found. Install it first, for example:" >&2
  echo "  python3 -m venv .venv" >&2
  echo "  .venv/bin/pip install zensical==0.0.68" >&2
  exit 1
fi

python3 ci/fetch-game-icons.py
zensical build --strict
python3 ci/check-doc-catalog.py

echo "test-docs ok"
