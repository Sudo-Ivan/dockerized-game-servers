#!/bin/sh
# Ensure poderized/minecraft/defaults.env matches Containerfile ARG and entrypoint fallbacks.

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "${ROOT}"

defaults="${ROOT}/poderized/minecraft/defaults.env"
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

expect VANILLA_VERSION "${VANILLA_VERSION}" poderized/minecraft/vanilla/Containerfile 'ARG VANILLA_VERSION='"${VANILLA_VERSION}"
expect VANILLA_VERSION "${VANILLA_VERSION}" poderized/minecraft/vanilla/entrypoint.sh 'VANILLA_VERSION:='"${VANILLA_VERSION}"

expect FABRIC_MINECRAFT_VERSION "${FABRIC_MINECRAFT_VERSION}" poderized/minecraft/fabric/Containerfile 'ARG FABRIC_MINECRAFT_VERSION='"${FABRIC_MINECRAFT_VERSION}"
expect FABRIC_LOADER_VERSION "${FABRIC_LOADER_VERSION}" poderized/minecraft/fabric/Containerfile 'ARG FABRIC_LOADER_VERSION='"${FABRIC_LOADER_VERSION}"
expect FABRIC_INSTALLER_VERSION "${FABRIC_INSTALLER_VERSION}" poderized/minecraft/fabric/Containerfile 'ARG FABRIC_INSTALLER_VERSION='"${FABRIC_INSTALLER_VERSION}"
expect FABRIC_MINECRAFT_VERSION "${FABRIC_MINECRAFT_VERSION}" poderized/minecraft/fabric/entrypoint.sh 'FABRIC_MINECRAFT_VERSION:='"${FABRIC_MINECRAFT_VERSION}"
expect FABRIC_LOADER_VERSION "${FABRIC_LOADER_VERSION}" poderized/minecraft/fabric/entrypoint.sh 'FABRIC_LOADER_VERSION:='"${FABRIC_LOADER_VERSION}"
expect FABRIC_INSTALLER_VERSION "${FABRIC_INSTALLER_VERSION}" poderized/minecraft/fabric/entrypoint.sh 'FABRIC_INSTALLER_VERSION:='"${FABRIC_INSTALLER_VERSION}"

expect FORGE_MINECRAFT_VERSION "${FORGE_MINECRAFT_VERSION}" poderized/minecraft/forge/Containerfile 'ARG FORGE_MINECRAFT_VERSION='"${FORGE_MINECRAFT_VERSION}"
expect FORGE_VERSION "${FORGE_VERSION}" poderized/minecraft/forge/Containerfile 'ARG FORGE_VERSION='"${FORGE_VERSION}"
expect FORGE_MINECRAFT_VERSION "${FORGE_MINECRAFT_VERSION}" poderized/minecraft/forge/entrypoint.sh 'FORGE_MINECRAFT_VERSION:='"${FORGE_MINECRAFT_VERSION}"
expect FORGE_VERSION "${FORGE_VERSION}" poderized/minecraft/forge/entrypoint.sh 'FORGE_VERSION:='"${FORGE_VERSION}"

expect NEOFORGE_VERSION "${NEOFORGE_VERSION}" poderized/minecraft/neoforge/Containerfile 'ARG NEOFORGE_VERSION='"${NEOFORGE_VERSION}"
expect NEOFORGE_VERSION "${NEOFORGE_VERSION}" poderized/minecraft/neoforge/entrypoint.sh 'NEOFORGE_VERSION:='"${NEOFORGE_VERSION}"

exit "${fail}"
