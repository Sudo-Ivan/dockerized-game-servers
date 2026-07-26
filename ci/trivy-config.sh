#!/bin/sh
# Scan Dockerfiles with a pinned Trivy CLI (misconfig only).

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "${ROOT}"

chmod +x "${ROOT}/ci/install-trivy.sh"
"${ROOT}/ci/install-trivy.sh"
export PATH="${HOME}/.local/bin:${PATH}"

echo "==> Trivy Dockerfile config scan"
trivy config \
  --config trivy.yaml \
  --misconfig-scanners dockerfile \
  --severity HIGH,CRITICAL \
  --exit-code 1 \
  .
