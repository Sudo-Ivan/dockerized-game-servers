#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
ENSHROUDED_APP_ID="${ENSHROUDED_APP_ID:-2278520}"
ENSHROUDED_FORCE_UPDATE="${ENSHROUDED_FORCE_UPDATE:-false}"

ENSHROUDED_SERVER_NAME="${ENSHROUDED_SERVER_NAME:-Enshrouded Server}"
ENSHROUDED_PASSWORD="${ENSHROUDED_PASSWORD:-}"
ENSHROUDED_GAME_PORT="${ENSHROUDED_GAME_PORT:-15636}"
ENSHROUDED_QUERY_PORT="${ENSHROUDED_QUERY_PORT:-15637}"
ENSHROUDED_SLOT_COUNT="${ENSHROUDED_SLOT_COUNT:-16}"
ENSHROUDED_BIND_IP="${ENSHROUDED_BIND_IP:-0.0.0.0}"
ENSHROUDED_EXTRA_ARGS="${ENSHROUDED_EXTRA_ARGS:-}"

WINEPREFIX="${WINEPREFIX:-${ENSHROUDED_DIR}/.wine}"
SERVER_CONFIG="${ENSHROUDED_DIR}/enshrouded_server.json"

server_bin() {
    find "${ENSHROUDED_DIR}" -maxdepth 2 -name 'enshrouded_server.exe' -print -quit 2>/dev/null
}

server_present() {
    [ -n "$(server_bin)" ]
}

relocate_install_if_needed() {
    if server_present; then
        return
    fi

    local alt_dir=""
    while IFS= read -r alt_dir; do
        if [ -n "$(find "${alt_dir}" -maxdepth 2 -name 'enshrouded_server.exe' -print -quit 2>/dev/null)" ]; then
            echo "--- Moving server files from ${alt_dir} to ${ENSHROUDED_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${ENSHROUDED_DIR}/${base}" ]; then
                    mv "${item}" "${ENSHROUDED_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/enshrouded/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

install_server() {
    echo "--- Installing Enshrouded dedicated server (App ${ENSHROUDED_APP_ID}) ---"
    mkdir -p "${ENSHROUDED_DIR}"
    steam_cleanup_incomplete_install "${ENSHROUDED_DIR}" "${ENSHROUDED_APP_ID}" "$(server_bin)"
    steam_prepare_install_dir "${ENSHROUDED_DIR}"

    local status=0
    steamcmd_invoke windows "${ENSHROUDED_DIR}" \
        +@sSteamCmdForcePlatformBitness 64 \
        +app_update "${ENSHROUDED_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "Enshrouded server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${ENSHROUDED_APP_ID}" "Enshrouded"
        exit 1
    fi

    relocate_install_if_needed

    if ! server_present; then
        echo "Enshrouded server install failed: enshrouded_server.exe not found." >&2
        exit 1
    fi
}

write_server_config() {
    if [ -f "${SERVER_CONFIG}" ]; then
        return
    fi
    echo "--- Writing default enshrouded_server.json ---"
    cat > "${SERVER_CONFIG}" <<EOF
{
  "name": "${ENSHROUDED_SERVER_NAME}",
  "password": "${ENSHROUDED_PASSWORD}",
  "saveDirectory": "./savegame",
  "logDirectory": "./logs",
  "ip": "${ENSHROUDED_BIND_IP}",
  "gamePort": ${ENSHROUDED_GAME_PORT},
  "queryPort": ${ENSHROUDED_QUERY_PORT},
  "slotCount": ${ENSHROUDED_SLOT_COUNT}
}
EOF
}

init_wine() {
    if [ ! -d "${WINEPREFIX}/drive_c" ]; then
        echo "--- Initializing Wine prefix at ${WINEPREFIX} ---"
        wineboot --init
        wineserver --wait
    fi
}

if ! server_present || [ "${ENSHROUDED_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

SERVER_BIN="$(server_bin)"
write_server_config
init_wine

cd "$(dirname "${SERVER_BIN}")"

args=()

# shellcheck disable=SC2206
if [ -n "${ENSHROUDED_EXTRA_ARGS}" ]; then
    extra=( ${ENSHROUDED_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting Enshrouded dedicated server on UDP ${ENSHROUDED_GAME_PORT}/${ENSHROUDED_QUERY_PORT} ---"
exec xvfb-run -a wine "$(basename "${SERVER_BIN}")" "${args[@]}"
