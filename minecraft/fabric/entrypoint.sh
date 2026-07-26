#!/bin/sh
set -eu

. /runtime.sh

: "${FABRIC_MINECRAFT_VERSION:=26.2}"
: "${FABRIC_LOADER_VERSION:=0.19.3}"
: "${FABRIC_INSTALLER_VERSION:=1.1.1}"
: "${FABRIC_FORCE_DOWNLOAD:=false}"
: "${EULA:=false}"

if [ -z "${SERVER_JAR:-}" ]; then
  SERVER_JAR="fabric-server-mc.${FABRIC_MINECRAFT_VERSION}-loader.${FABRIC_LOADER_VERSION}-launcher.${FABRIC_INSTALLER_VERSION}.jar"
fi

download_fabric() {
  download_url="https://meta.fabricmc.net/v2/versions/loader/${FABRIC_MINECRAFT_VERSION}/${FABRIC_LOADER_VERSION}/${FABRIC_INSTALLER_VERSION}/server/jar"
  mc_validate_https_url "${download_url}" meta.fabricmc.net || exit 1
  echo "Downloading Fabric server launcher (${FABRIC_MINECRAFT_VERSION}/${FABRIC_LOADER_VERSION}/${FABRIC_INSTALLER_VERSION})"
  curl -fsSL "${download_url}" -o "${SERVER_JAR}"
}

mc_ensure_run_user

case "${EULA}" in
  true|TRUE|yes|YES|y|Y)
    echo "eula=true" > eula.txt
    ;;
esac

if [ ! -f "${SERVER_JAR}" ] || [ "${FABRIC_FORCE_DOWNLOAD}" = "true" ] || [ "${FABRIC_FORCE_DOWNLOAD}" = "TRUE" ]; then
  download_fabric
fi

mc_run_java -jar "${SERVER_JAR}" nogui
