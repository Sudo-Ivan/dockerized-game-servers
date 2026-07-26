#!/bin/sh
# Install a pinned Trivy CLI release with SHA-256 verification.
# Avoids aquasecurity/trivy-action after the March 2026 supply-chain incident.

set -eu

TRIVY_VERSION="${TRIVY_VERSION:-0.72.0}"
TRIVY_SHA256="${TRIVY_SHA256:-bbb64b9695866ce4a7a8f5c9592002c5961cab378577fa3f8a040df362b9b2ea}"
INSTALL_DIR="${TRIVY_INSTALL_DIR:-${HOME}/.local/bin}"
ARCHIVE="trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz"
BASE_URL="https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}"

case "$(uname -s)-$(uname -m)" in
  Linux-x86_64|Linux-amd64) ;;
  *)
    echo "Unsupported platform for pinned Trivy install: $(uname -s)-$(uname -m)" >&2
    exit 1
    ;;
esac

if command -v trivy >/dev/null 2>&1; then
  installed="$(trivy version 2>/dev/null | awk '/Version/{print $2; exit}')"
  if [ "${installed}" = "${TRIVY_VERSION}" ]; then
    echo "Trivy ${TRIVY_VERSION} already installed"
    command -v trivy
    exit 0
  fi
fi

tmpdir="$(mktemp -d)"
cleanup() {
  rm -rf "${tmpdir}"
}
trap cleanup EXIT INT TERM

echo "Downloading Trivy v${TRIVY_VERSION}"
curl -fsSL "${BASE_URL}/${ARCHIVE}" -o "${tmpdir}/${ARCHIVE}"
echo "${TRIVY_SHA256}  ${tmpdir}/${ARCHIVE}" | sha256sum -c -

tar -xzf "${tmpdir}/${ARCHIVE}" -C "${tmpdir}" trivy
mkdir -p "${INSTALL_DIR}"
install -m 755 "${tmpdir}/trivy" "${INSTALL_DIR}/trivy"

case ":${PATH}:" in
  *":${INSTALL_DIR}:"*) ;;
  *)
    export PATH="${INSTALL_DIR}:${PATH}"
    if [ -n "${GITHUB_PATH:-}" ]; then
      echo "${INSTALL_DIR}" >>"${GITHUB_PATH}"
    fi
    ;;
esac

trivy version
echo "Installed ${INSTALL_DIR}/trivy"
