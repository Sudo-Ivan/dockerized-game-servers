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
if ! podman image inspect "${IMAGE_REF}" >/dev/null 2>&1; then
  echo "Local image missing, pulling ${IMAGE_REF}"
  podman pull "${IMAGE_REF}"
fi

# Trivy reads podman through the user API socket. Bring it up when absent
# (CI runners have no user session bus).
PODMAN_SOCK_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/podman"
PODMAN_SOCK="${PODMAN_SOCK_DIR}/podman.sock"
if [ ! -S "${PODMAN_SOCK}" ]; then
  systemctl --user start podman.socket 2>/dev/null \
    || { mkdir -p "${PODMAN_SOCK_DIR}"; (podman system service --time=300 "unix://${PODMAN_SOCK}" >/dev/null 2>&1 &); }
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    [ -S "${PODMAN_SOCK}" ] && break
    sleep 1
  done
fi

trivy image \
  --image-src podman \
  --config poderized/trivy.yaml \
  --ignorefile poderized/.trivyignore \
  --scanners vuln,secret,misconfig \
  --misconfig-scanners dockerfile \
  --severity CRITICAL \
  --ignore-unfixed \
  --exit-code 1 \
  "${IMAGE_REF}"
