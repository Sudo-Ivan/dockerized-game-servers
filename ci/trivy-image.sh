#!/bin/sh
# Scan a container image with a pinned Trivy CLI.
# Usage: trivy-image.sh <image-ref>
# Fails on CRITICAL only. Arch rolling packages often report HIGH noise.

set -eu

IMAGE_REF="${1:?image ref required}"

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "${ROOT}"

chmod +x "${ROOT}/ci/install-trivy.sh"
"${ROOT}/ci/install-trivy.sh"
export PATH="${HOME}/.local/bin:${PATH}"

echo "==> Trivy image scan: ${IMAGE_REF}"
trivy image \
  --config trivy.yaml \
  --scanners vuln,secret,misconfig \
  --misconfig-scanners dockerfile \
  --severity CRITICAL \
  --ignore-unfixed \
  --exit-code 1 \
  "${IMAGE_REF}"
