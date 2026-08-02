#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
SOTF_APP_ID="${SOTF_APP_ID:-2465200}"
SOTF_STEAM_APP_ID="${SOTF_STEAM_APP_ID:-1326470}"
SOTF_FORCE_UPDATE="${SOTF_FORCE_UPDATE:-false}"

SOTF_IP="${SOTF_IP:-0.0.0.0}"
SOTF_GAME_PORT="${SOTF_GAME_PORT:-8766}"
SOTF_QUERY_PORT="${SOTF_QUERY_PORT:-27016}"
SOTF_BLOB_SYNC_PORT="${SOTF_BLOB_SYNC_PORT:-9700}"
SOTF_SERVER_NAME="${SOTF_SERVER_NAME:-Sons Of The Forest Server (dedicated)}"
SOTF_MAX_PLAYERS="${SOTF_MAX_PLAYERS:-8}"
SOTF_PASSWORD="${SOTF_PASSWORD:-}"
SOTF_LAN_ONLY="${SOTF_LAN_ONLY:-false}"
SOTF_SAVE_SLOT="${SOTF_SAVE_SLOT:-1}"
SOTF_SAVE_MODE="${SOTF_SAVE_MODE:-Continue}"
SOTF_GAME_MODE="${SOTF_GAME_MODE:-Normal}"
SOTF_SAVE_INTERVAL="${SOTF_SAVE_INTERVAL:-600}"
SOTF_EXTRA_ARGS="${SOTF_EXTRA_ARGS:-}"

WINEPREFIX="${WINEPREFIX:-${SOTF_DIR}/.wine}"
SOTF_USERDATA_DIR="${SOTF_DIR}/userdata"

server_bin() {
    find "${SOTF_DIR}" -maxdepth 2 -name 'SonsOfTheForestDS.exe' -print -quit 2>/dev/null
}

server_present() {
    [ -n "$(server_bin)" ]
}

prepare_steam_install_dir() {
    steam_prepare_install_dir "${SOTF_DIR}"
}

cleanup_incomplete_install() {
    local ready=""
    ready="$(server_bin)"
    steam_cleanup_incomplete_install "${SOTF_DIR}" "${SOTF_APP_ID}" "${ready}"
}

relocate_install_if_needed() {
    if server_present; then
        return
    fi

    local alt_dir=""
    while IFS= read -r alt_dir; do
        if [ -n "$(find "${alt_dir}" -maxdepth 2 -name 'SonsOfTheForestDS.exe' -print -quit 2>/dev/null)" ]; then
            echo "--- Moving server files from ${alt_dir} to ${SOTF_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${SOTF_DIR}/${base}" ]; then
                    mv "${item}" "${SOTF_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/sotf/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

install_server() {
    echo "--- Installing Sons Of The Forest dedicated server (App ${SOTF_APP_ID}) ---"
    mkdir -p "${SOTF_DIR}"
    cleanup_incomplete_install
    prepare_steam_install_dir

    local status=0
    steamcmd_invoke windows "${SOTF_DIR}" \
        +@sSteamCmdForcePlatformBitness 64 \
        +app_update "${SOTF_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "Sons Of The Forest server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${SOTF_APP_ID}" "Sons Of The Forest"
        exit 1
    fi

    relocate_install_if_needed

    if ! server_present; then
        echo "Sons Of The Forest server install failed: SonsOfTheForestDS.exe not found." >&2
        find "${SOTF_DIR}" -maxdepth 4 -type f -name '*.exe' 2>/dev/null | head -20 >&2 || true
        exit 1
    fi
}

write_dedicated_server_cfg() {
    local cfg="${SOTF_USERDATA_DIR}/dedicatedserver.cfg"
    if [ -f "${cfg}" ]; then
        return
    fi
    echo "--- Writing default dedicatedserver.cfg ---"
    mkdir -p "${SOTF_USERDATA_DIR}"
    cat > "${cfg}" <<EOF
{
  "IpAddress": "${SOTF_IP}",
  "GamePort": ${SOTF_GAME_PORT},
  "QueryPort": ${SOTF_QUERY_PORT},
  "BlobSyncPort": ${SOTF_BLOB_SYNC_PORT},
  "ServerName": "${SOTF_SERVER_NAME}",
  "MaxPlayers": ${SOTF_MAX_PLAYERS},
  "Password": "${SOTF_PASSWORD}",
  "LanOnly": ${SOTF_LAN_ONLY},
  "SaveSlot": ${SOTF_SAVE_SLOT},
  "SaveMode": "${SOTF_SAVE_MODE}",
  "GameMode": "${SOTF_GAME_MODE}",
  "SaveInterval": ${SOTF_SAVE_INTERVAL},
  "IdleDayCycleSpeed": 0.0,
  "IdleTargetFramerate": 5,
  "ActiveTargetFramerate": 60,
  "LogFilesEnabled": false,
  "TimestampLogFilenames": true,
  "TimestampLogEntries": true,
  "GameSettings": {},
  "CustomGameModeSettings": {}
}
EOF
}

write_owners_whitelist() {
    local whitelist="${SOTF_USERDATA_DIR}/ownerswhitelist.txt"
    if [ -f "${whitelist}" ]; then
        return
    fi
    mkdir -p "${SOTF_USERDATA_DIR}"
    : > "${whitelist}"
}

init_wine() {
    if [ ! -d "${WINEPREFIX}/drive_c" ]; then
        echo "--- Initializing Wine prefix at ${WINEPREFIX} ---"
        wineboot --init
        wineserver --wait
    fi
}

if ! server_present || [ "${SOTF_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

SERVER_BIN="$(server_bin)"
printf '%s\n' "${SOTF_STEAM_APP_ID}" > "${SOTF_DIR}/steam_appid.txt"

write_dedicated_server_cfg
write_owners_whitelist

init_wine

cd "$(dirname "${SERVER_BIN}")"

args=(
    -batchmode
    -nographics
    -userdatapath "${SOTF_USERDATA_DIR}"
)

# shellcheck disable=SC2206
if [ -n "${SOTF_EXTRA_ARGS}" ]; then
    extra=( ${SOTF_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting Sons Of The Forest dedicated server on UDP ${SOTF_GAME_PORT} ---"
exec wine "$(basename "${SERVER_BIN}")" "${args[@]}"
