#!/bin/sh
# Resolve Minecraft image build inputs (Java, Fabric/Forge, tags).
# Usage:
#   resolve-minecraft-build.sh --flavor fabric --minecraft-version 26.2
# Prints KEY=VALUE lines. With --github-output FILE also appends for Actions.

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
exec python3 "${ROOT}/ci/resolve-minecraft-build.py" "$@"
