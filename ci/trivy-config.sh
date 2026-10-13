#!/bin/sh
# Scan Containerfiles with a pinned Trivy CLI (misconfig only).

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "${ROOT}"

chmod +x "${ROOT}/ci/install-trivy.sh"
"${ROOT}/ci/install-trivy.sh"
export PATH="${HOME}/.local/bin:${PATH}"

echo "==> Trivy Containerfile config scan"
trivy config \
  --config poderized/trivy.yaml \
  --ignorefile poderized/.trivyignore \
  --misconfig-scanners dockerfile \
  --severity MEDIUM,HIGH,CRITICAL \
  --exit-code 1 \
  poderized
