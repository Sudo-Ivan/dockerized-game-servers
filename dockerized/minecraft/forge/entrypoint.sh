#!/bin/sh
set -eu

# shellcheck disable=SC1091
. /runtime.sh

: "${FORGE_MINECRAFT_VERSION:=26.2}"
: "${FORGE_VERSION:=65.0.9}"
: "${FORGE_INSTALLER_URL:=}"
: "${FORGE_FORCE_INSTALL:=false}"
: "${FORGE_INSTALL_DIR:=/data}"
: "${FORGE_SERVER_JAR:=}"
: "${SERVER_JAR:=}"
: "${FORGE_RUN_SCRIPT:=run.sh}"
: "${EULA:=false}"

if [ -z "${FORGE_INSTALLER_URL}" ]; then
  FORGE_INSTALLER_URL="https://maven.minecraftforge.net/net/minecraftforge/forge/${FORGE_MINECRAFT_VERSION}-${FORGE_VERSION}/forge-${FORGE_MINECRAFT_VERSION}-${FORGE_VERSION}-installer.jar"
fi

if [ -z "${FORGE_SERVER_JAR}" ]; then
  FORGE_SERVER_JAR="forge-${FORGE_MINECRAFT_VERSION}-${FORGE_VERSION}-server.jar"
fi

if [ -z "${SERVER_JAR}" ]; then
  SERVER_JAR="${FORGE_SERVER_JAR}"
fi

download_installer() {
  mc_validate_https_url "${FORGE_INSTALLER_URL}" maven.minecraftforge.net || exit 1
  echo "Downloading Forge installer ${FORGE_MINECRAFT_VERSION}-${FORGE_VERSION}"
  curl -fsSL "${FORGE_INSTALLER_URL}" -o /tmp/forge-installer.jar
}

install_forge() {
  echo "Installing Forge server to ${FORGE_INSTALL_DIR}"
  # JAVA_SECURE_FLAGS is a space-separated option list
  # shellcheck disable=SC2086
  java ${JAVA_SECURE_FLAGS} -jar /tmp/forge-installer.jar --installServer "${FORGE_INSTALL_DIR}"
  rm -f /tmp/forge-installer.jar

  if [ -f "${FORGE_INSTALL_DIR}/libraries/net/minecraftforge/forge/${FORGE_MINECRAFT_VERSION}-${FORGE_VERSION}/forge-${FORGE_MINECRAFT_VERSION}-${FORGE_VERSION}-server.jar" ]; then
    ln -sf "${FORGE_INSTALL_DIR}/libraries/net/minecraftforge/forge/${FORGE_MINECRAFT_VERSION}-${FORGE_VERSION}/forge-${FORGE_MINECRAFT_VERSION}-${FORGE_VERSION}-server.jar" "${FORGE_INSTALL_DIR}/${FORGE_SERVER_JAR}"
  fi
}

mc_ensure_run_user

case "${EULA}" in
  true|TRUE|yes|YES|y|Y)
    echo "eula=true" > eula.txt
    ;;
esac

if [ "${FORGE_FORCE_INSTALL}" = "true" ] || [ "${FORGE_FORCE_INSTALL}" = "TRUE" ] || [ ! -f "${FORGE_INSTALL_DIR}/${FORGE_SERVER_JAR}" ]; then
  download_installer
  install_forge
fi

if [ -n "${JVM_FLAGS:-}" ]; then
  printf "%s\n" "${JVM_FLAGS}" > "${FORGE_INSTALL_DIR}/user_jvm_args.txt"
fi

if [ -f "${FORGE_INSTALL_DIR}/${FORGE_RUN_SCRIPT}" ]; then
  chmod +x "${FORGE_INSTALL_DIR}/${FORGE_RUN_SCRIPT}"
  if [ "$(id -u)" -eq 0 ] && [ -n "${MC_RUN_USER:-}" ]; then
    exec su -s /bin/sh "${MC_RUN_USER}" -c "cd \"${FORGE_INSTALL_DIR}\" && PATH=\"${PATH}\" exec ./${FORGE_RUN_SCRIPT} nogui"
  fi
  exec "${FORGE_INSTALL_DIR}/${FORGE_RUN_SCRIPT}" nogui
fi

if [ -f "${FORGE_INSTALL_DIR}/unix_args.txt" ]; then
  mc_run_java @"${FORGE_INSTALL_DIR}/unix_args.txt" nogui
fi

mc_run_java -jar "${SERVER_JAR}" nogui
