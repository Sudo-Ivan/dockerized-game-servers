#!/bin/sh
# Scan a published container image with a pinned Trivy CLI.
# Usage: trivy-image.sh <image-ref>
# Fails on CRITICAL only. Arch rolling packages often report HIGH noise.
#
# The scan reads the image from the registry (remote source). Published images
# use zstd layers, and trivy cannot read those back through podman save on the
# podman shipped by GitHub runners. Set TRIVY_USERNAME and TRIVY_PASSWORD for
# private packages.

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
trivy image \
  --image-src remote \
  --config poderized/trivy.yaml \
  --ignorefile poderized/.trivyignore \
  --scanners vuln,secret,misconfig \
  --misconfig-scanners dockerfile \
  --severity CRITICAL \
  --ignore-unfixed \
  --exit-code 1 \
  "${IMAGE_REF}"
