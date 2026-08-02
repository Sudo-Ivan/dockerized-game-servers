#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

mkdir -p "${ARMA_DIR}/keys" "${ARMA_DIR}/mpmissions"

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
ARMA_APP_ID="${ARMA_APP_ID:-233780}"

if [ -z "${STEAM_USERNAME}" ]; then
    STEAM_USERNAME="anonymous"
fi

if [ ! -f "${ARMA_DIR}/arma3server_x64" ]; then
    echo "--- Installing Arma 3 server (App ${ARMA_APP_ID}) ---"
    STEAM_LOGIN="$(steam_login_args)"
    # shellcheck disable=SC2086
    ${STEAM_DIR}/steamcmd.sh +force_install_dir ${ARMA_DIR} +login ${STEAM_LOGIN} +app_update ${ARMA_APP_ID} validate +quit
fi

if [ ! -f "${ARMA_DIR}/arma3server_x64" ]; then
    echo "Arma 3 server binary not found at ${ARMA_DIR}/arma3server_x64" >&2
    steam_install_anonymous_hint "${ARMA_APP_ID}" "Arma 3 Server" >&2
    exit 1
fi

chmod +x "${ARMA_DIR}/arma3server_x64"

echo "--- Starting Arma 3 panel ---"
exec /home/arma3/bin/arma-panel
