#!/bin/sh
# Ensure minecraft/defaults.env matches Dockerfile ARG and entrypoint fallbacks.

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "${ROOT}"

defaults="${ROOT}/minecraft/defaults.env"
if [ ! -f "${defaults}" ]; then
  echo "missing ${defaults}" >&2
  exit 1
fi

# shellcheck disable=SC1090
. "${defaults}"

fail=0

expect() {
  name="$1"
  want="$2"
  file="$3"
  pattern="$4"
  if ! grep -qE "${pattern}" "${file}"; then
    echo "minecraft default mismatch: ${name}=${want} not found in ${file}" >&2
    fail=1
  fi
}

expect VANILLA_VERSION "${VANILLA_VERSION}" minecraft/vanilla/Dockerfile 'ARG VANILLA_VERSION='"${VANILLA_VERSION}"
expect VANILLA_VERSION "${VANILLA_VERSION}" minecraft/vanilla/entrypoint.sh 'VANILLA_VERSION:='"${VANILLA_VERSION}"

expect FABRIC_MINECRAFT_VERSION "${FABRIC_MINECRAFT_VERSION}" minecraft/fabric/Dockerfile 'ARG FABRIC_MINECRAFT_VERSION='"${FABRIC_MINECRAFT_VERSION}"
expect FABRIC_LOADER_VERSION "${FABRIC_LOADER_VERSION}" minecraft/fabric/Dockerfile 'ARG FABRIC_LOADER_VERSION='"${FABRIC_LOADER_VERSION}"
expect FABRIC_INSTALLER_VERSION "${FABRIC_INSTALLER_VERSION}" minecraft/fabric/Dockerfile 'ARG FABRIC_INSTALLER_VERSION='"${FABRIC_INSTALLER_VERSION}"
expect FABRIC_MINECRAFT_VERSION "${FABRIC_MINECRAFT_VERSION}" minecraft/fabric/entrypoint.sh 'FABRIC_MINECRAFT_VERSION:='"${FABRIC_MINECRAFT_VERSION}"
expect FABRIC_LOADER_VERSION "${FABRIC_LOADER_VERSION}" minecraft/fabric/entrypoint.sh 'FABRIC_LOADER_VERSION:='"${FABRIC_LOADER_VERSION}"
expect FABRIC_INSTALLER_VERSION "${FABRIC_INSTALLER_VERSION}" minecraft/fabric/entrypoint.sh 'FABRIC_INSTALLER_VERSION:='"${FABRIC_INSTALLER_VERSION}"

expect FORGE_MINECRAFT_VERSION "${FORGE_MINECRAFT_VERSION}" minecraft/forge/Dockerfile 'ARG FORGE_MINECRAFT_VERSION='"${FORGE_MINECRAFT_VERSION}"
expect FORGE_VERSION "${FORGE_VERSION}" minecraft/forge/Dockerfile 'ARG FORGE_VERSION='"${FORGE_VERSION}"
expect FORGE_MINECRAFT_VERSION "${FORGE_MINECRAFT_VERSION}" minecraft/forge/entrypoint.sh 'FORGE_MINECRAFT_VERSION:='"${FORGE_MINECRAFT_VERSION}"
expect FORGE_VERSION "${FORGE_VERSION}" minecraft/forge/entrypoint.sh 'FORGE_VERSION:='"${FORGE_VERSION}"

expect NEOFORGE_VERSION "${NEOFORGE_VERSION}" minecraft/neoforge/Dockerfile 'ARG NEOFORGE_VERSION='"${NEOFORGE_VERSION}"
expect NEOFORGE_VERSION "${NEOFORGE_VERSION}" minecraft/neoforge/entrypoint.sh 'NEOFORGE_VERSION:='"${NEOFORGE_VERSION}"

exit "${fail}"
