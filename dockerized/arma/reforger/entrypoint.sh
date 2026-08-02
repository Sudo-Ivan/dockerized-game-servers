#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
ARMAR_APP_ID="${ARMAR_APP_ID:-1874900}"
ARMAR_FORCE_UPDATE="${ARMAR_FORCE_UPDATE:-false}"
STEAMCMD_WINDOWS_WORKAROUND="${STEAMCMD_WINDOWS_WORKAROUND:-full}"

ARMAR_BIND_PORT="${ARMAR_BIND_PORT:-2001}"
ARMAR_A2S_PORT="${ARMAR_A2S_PORT:-17777}"
ARMAR_MAX_FPS="${ARMAR_MAX_FPS:-60}"
ARMAR_MAX_PLAYERS="${ARMAR_MAX_PLAYERS:-16}"
ARMAR_SERVER_NAME="${ARMAR_SERVER_NAME:-Arma Reforger Server}"
ARMAR_SCENARIO_ID="${ARMAR_SCENARIO_ID:-{59AD59368755F41A}Missions/23_Campaign.conf}"
ARMAR_EXTRA_ARGS="${ARMAR_EXTRA_ARGS:-}"

SERVER_BIN="${ARMAR_DIR}/ArmaReforgerServer"
CONFIG_FILE="${ARMAR_DIR}/Configs/ServerConfig.json"
PROFILE_DIR="${ARMAR_DIR}/profile"

server_present() {
    [ -f "${SERVER_BIN}" ]
}

relocate_install_if_needed() {
    if server_present; then
        return
    fi
    local alt_dir=""
    while IFS= read -r alt_dir; do
        if [ -f "${alt_dir}/ArmaReforgerServer" ]; then
            echo "--- Moving Arma Reforger server files from ${alt_dir} to ${ARMAR_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${ARMAR_DIR}/${base}" ]; then
                    mv "${item}" "${ARMAR_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/armar/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

install_server() {
    echo "--- Installing Arma Reforger dedicated server (App ${ARMAR_APP_ID}) ---"
    mkdir -p "${ARMAR_DIR}"
    steam_cleanup_incomplete_install "${ARMAR_DIR}" "${ARMAR_APP_ID}" "${SERVER_BIN}"
    steam_prepare_install_dir "${ARMAR_DIR}"

    local status=0
    steamcmd_install_linux_app "${ARMAR_DIR}" "${ARMAR_APP_ID}" \
        +app_update "${ARMAR_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "Arma Reforger server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${ARMAR_APP_ID}" "Arma Reforger"
        exit 1
    fi

    relocate_install_if_needed

    if ! server_present; then
        echo "Arma Reforger server install failed: ${SERVER_BIN} not found." >&2
        exit 1
    fi

    chmod +x "${SERVER_BIN}"
}

write_default_config() {
    mkdir -p "$(dirname "${CONFIG_FILE}")" "${PROFILE_DIR}"
    if [ -f "${CONFIG_FILE}" ]; then
        return
    fi
    cat >"${CONFIG_FILE}" <<EOF
{
  "bindAddress": "0.0.0.0",
  "bindPort": ${ARMAR_BIND_PORT},
  "publicAddress": "",
  "publicPort": ${ARMAR_BIND_PORT},
  "a2s": {
    "address": "0.0.0.0",
    "port": ${ARMAR_A2S_PORT}
  },
  "game": {
    "name": "${ARMAR_SERVER_NAME}",
    "password": "",
    "scenarioId": "${ARMAR_SCENARIO_ID}",
    "maxPlayers": ${ARMAR_MAX_PLAYERS},
    "visible": true,
    "crossPlatform": true,
    "supportedPlatforms": ["PLATFORM_PC"],
    "gameProperties": {
      "serverMaxViewDistance": 1600,
      "serverMinGrassDistance": 50,
      "networkViewDistance": 1500,
      "disableThirdPerson": false,
      "fastValidation": true,
      "battlEye": true
    },
    "mods": []
  },
  "operating": {
    "lobbyPlayerSynchronise": true,
    "disableServerShutdown": false,
    "playerSaveTime": 120
  }
}
EOF
}

if ! server_present || [ "${ARMAR_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

write_default_config

cd "${ARMAR_DIR}"
chmod +x "${SERVER_BIN}"

args=(
    -config "${CONFIG_FILE}"
    -maxFPS "${ARMAR_MAX_FPS}"
    -profile "${PROFILE_DIR}"
)

# shellcheck disable=SC2206
if [ -n "${ARMAR_EXTRA_ARGS}" ]; then
    extra=( ${ARMAR_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting Arma Reforger dedicated server (UDP ${ARMAR_BIND_PORT}) ---"
exec "${SERVER_BIN}" "${args[@]}"
