#!/bin/sh
set -eu

# shellcheck disable=SC1091
. /runtime.sh

: "${VANILLA_VERSION:=1.21.11}"
: "${VANILLA_JAR_URL:=}"
: "${VANILLA_FORCE_DOWNLOAD:=false}"
: "${SERVER_JAR:=server.jar}"
: "${EULA:=false}"

MOJANG_HOSTS="piston-meta.mojang.com piston-data.mojang.com launchermeta.mojang.com minecraft.azureedge.net"

download_vanilla() {
  if [ -n "${VANILLA_JAR_URL}" ]; then
    # MOJANG_HOSTS is a space-separated allowlist
    # shellcheck disable=SC2086
    if ! mc_url_allowed "${VANILLA_JAR_URL}" ${MOJANG_HOSTS}; then
      echo "URL host not allowed: ${VANILLA_JAR_URL}" >&2
      exit 1
    fi
    download_url="${VANILLA_JAR_URL}"
    echo "Downloading vanilla Minecraft server from configured URL"
    curl -fsSL "${download_url}" -o "${SERVER_JAR}"
    return 0
  fi

  manifest_url="https://piston-meta.mojang.com/mc/game/version_manifest_v2.json"
  mc_validate_https_url "${manifest_url}" piston-meta.mojang.com || exit 1
  version_url="$(curl -fsSL "${manifest_url}" | jq -r --arg version "${VANILLA_VERSION}" '.versions[] | select(.id == $version) | .url')"
  if [ -z "${version_url}" ] || [ "${version_url}" = "null" ]; then
    echo "Failed to resolve vanilla version ${VANILLA_VERSION}." >&2
    exit 1
  fi
  mc_validate_https_url "${version_url}" piston-meta.mojang.com || exit 1

  version_json="$(curl -fsSL "${version_url}")"
  server_url="$(printf '%s' "${version_json}" | jq -r '.downloads.server.url')"
  server_sha1="$(printf '%s' "${version_json}" | jq -r '.downloads.server.sha1')"
  if [ -z "${server_url}" ] || [ "${server_url}" = "null" ]; then
    echo "Failed to resolve server jar URL for ${VANILLA_VERSION}." >&2
    exit 1
  fi
  if [ -z "${server_sha1}" ] || [ "${server_sha1}" = "null" ]; then
    echo "Failed to resolve server jar checksum for ${VANILLA_VERSION}." >&2
    exit 1
  fi

  # MOJANG_HOSTS is a space-separated allowlist
  # shellcheck disable=SC2086
  if ! mc_url_allowed "${server_url}" ${MOJANG_HOSTS}; then
    echo "URL host not allowed: ${server_url}" >&2
    exit 1
  fi

  echo "Downloading vanilla Minecraft server ${VANILLA_VERSION}"
  curl -fsSL "${server_url}" -o "${SERVER_JAR}"
  printf '%s  %s\n' "${server_sha1}" "${SERVER_JAR}" | sha1sum -c -
}

mc_ensure_run_user

case "${EULA}" in
  true|TRUE|yes|YES|y|Y)
    echo "eula=true" > eula.txt
    ;;
esac

if [ ! -f "${SERVER_JAR}" ] || [ "${VANILLA_FORCE_DOWNLOAD}" = "true" ] || [ "${VANILLA_FORCE_DOWNLOAD}" = "TRUE" ]; then
  download_vanilla
fi

mc_run_java -jar "${SERVER_JAR}" nogui
