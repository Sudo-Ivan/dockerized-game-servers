#!/bin/sh
set -eu

# shellcheck disable=SC1091
. /runtime.sh

: "${NEOFORGE_VERSION:=26.2.0.35-beta}"
: "${NEOFORGE_INSTALLER_URL:=}"
: "${NEOFORGE_FORCE_INSTALL:=false}"
: "${NEOFORGE_INSTALL_DIR:=/data}"
: "${NEOFORGE_SERVER_JAR:=}"
: "${SERVER_JAR:=}"
: "${NEOFORGE_RUN_SCRIPT:=run.sh}"
: "${EULA:=false}"

NEOFORGE_MAVEN_HOST="maven.neoforged.net"

if [ -z "${NEOFORGE_INSTALLER_URL}" ]; then
  NEOFORGE_INSTALLER_URL="https://${NEOFORGE_MAVEN_HOST}/releases/net/neoforged/neoforge/${NEOFORGE_VERSION}/neoforge-${NEOFORGE_VERSION}-installer.jar"
fi

if [ -z "${NEOFORGE_SERVER_JAR}" ]; then
  NEOFORGE_SERVER_JAR="neoforge-${NEOFORGE_VERSION}-server.jar"
fi

if [ -z "${SERVER_JAR}" ]; then
  SERVER_JAR="${NEOFORGE_SERVER_JAR}"
fi

download_installer() {
  mc_validate_https_url "${NEOFORGE_INSTALLER_URL}" "${NEOFORGE_MAVEN_HOST}" || exit 1
  echo "Downloading NeoForge installer ${NEOFORGE_VERSION}"
  curl -fsSL "${NEOFORGE_INSTALLER_URL}" -o /tmp/neoforge-installer.jar
}

install_neoforge() {
  echo "Installing NeoForge server to ${NEOFORGE_INSTALL_DIR}"
  # JAVA_SECURE_FLAGS is a space-separated option list
  # shellcheck disable=SC2086
  java ${JAVA_SECURE_FLAGS} -jar /tmp/neoforge-installer.jar --installServer "${NEOFORGE_INSTALL_DIR}"
  rm -f /tmp/neoforge-installer.jar

  lib_jar="${NEOFORGE_INSTALL_DIR}/libraries/net/neoforged/neoforge/${NEOFORGE_VERSION}/neoforge-${NEOFORGE_VERSION}-server.jar"
  if [ -f "${lib_jar}" ]; then
    ln -sf "${lib_jar}" "${NEOFORGE_INSTALL_DIR}/${NEOFORGE_SERVER_JAR}"
  fi
}

mc_ensure_run_user

case "${EULA}" in
  true|TRUE|yes|YES|y|Y)
    echo "eula=true" > eula.txt
    ;;
esac

if [ "${NEOFORGE_FORCE_INSTALL}" = "true" ] || [ "${NEOFORGE_FORCE_INSTALL}" = "TRUE" ] || [ ! -f "${NEOFORGE_INSTALL_DIR}/${NEOFORGE_SERVER_JAR}" ]; then
  download_installer
  install_neoforge
fi

if [ -n "${JVM_FLAGS:-}" ]; then
  printf "%s\n" "${JVM_FLAGS}" > "${NEOFORGE_INSTALL_DIR}/user_jvm_args.txt"
fi

if [ -f "${NEOFORGE_INSTALL_DIR}/${NEOFORGE_RUN_SCRIPT}" ]; then
  chmod +x "${NEOFORGE_INSTALL_DIR}/${NEOFORGE_RUN_SCRIPT}"
  if [ "$(id -u)" -eq 0 ] && [ -n "${MC_RUN_USER:-}" ]; then
    exec su -s /bin/sh "${MC_RUN_USER}" -c "cd \"${NEOFORGE_INSTALL_DIR}\" && PATH=\"${PATH}\" exec ./${NEOFORGE_RUN_SCRIPT} nogui"
  fi
  exec "${NEOFORGE_INSTALL_DIR}/${NEOFORGE_RUN_SCRIPT}" nogui
fi

if [ -f "${NEOFORGE_INSTALL_DIR}/unix_args.txt" ]; then
  mc_run_java @"${NEOFORGE_INSTALL_DIR}/unix_args.txt" nogui
fi

mc_run_java -jar "${SERVER_JAR}" nogui
