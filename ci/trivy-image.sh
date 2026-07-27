#!/bin/sh
# Scan a container image with a pinned Trivy CLI.
# Usage: trivy-image.sh <image-ref>
# Fails on CRITICAL only. Arch rolling packages often report HIGH noise.

set -eu

IMAGE_REF="${1:?image ref required}"
# OCI/GHCR image references must be lowercase.
IMAGE_REF="$(printf '%s' "${IMAGE_REF}" | tr '[:upper:]' '[:lower:]')"

ROOT="$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)"
cd "${ROOT}"

chmod +x "${ROOT}/ci/install-trivy.sh"
"${ROOT}/ci/install-trivy.sh"
export PATH="${HOME}/.local/bin:${PATH}"

echo "==> Trivy image scan: ${IMAGE_REF}"
if ! docker image inspect "${IMAGE_REF}" >/dev/null 2>&1; then
  echo "Local image missing, pulling ${IMAGE_REF}"
  docker pull "${IMAGE_REF}"
fi
trivy image \
  --config trivy.yaml \
  --scanners vuln,secret,misconfig \
  --misconfig-scanners dockerfile \
  --severity CRITICAL \
  --ignore-unfixed \
  --exit-code 1 \
  "${IMAGE_REF}"
