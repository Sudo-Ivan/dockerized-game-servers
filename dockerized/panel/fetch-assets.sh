#!/bin/sh
set -eu

ROOT="$(cd "$(dirname "$0")" && pwd)"
OUT="$ROOT/internal/web/static/htmx.min.js"
URL="https://unpkg.com/htmx.org@2.0.4/dist/htmx.min.js"

if [ -f "$OUT" ] && [ -s "$OUT" ]; then
  exit 0
fi

if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$URL" -o "$OUT"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$OUT" "$URL"
else
  echo "curl or wget required to fetch htmx.min.js" >&2
  exit 1
fi
