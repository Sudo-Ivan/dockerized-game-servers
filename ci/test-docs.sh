#!/bin/sh
# Build docs and run link/catalog checks.

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "${ROOT}/docs"

if ! command -v pnpm >/dev/null 2>&1; then
  echo "pnpm not installed" >&2
  exit 1
fi

pnpm install --frozen-lockfile
pnpm run build
node scripts/check-doc-links.mjs
node scripts/check-doc-catalog.mjs

echo "test-docs ok"
