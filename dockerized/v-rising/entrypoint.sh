#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
VRISING_APP_ID="${VRISING_APP_ID:-1829350}"
VRISING_STEAM_APP_ID="${VRISING_STEAM_APP_ID:-1604030}"
VRISING_FORCE_UPDATE="${VRISING_FORCE_UPDATE:-false}"

VRISING_PORT="${VRISING_PORT:-9876}"
VRISING_QUERY_PORT="${VRISING_QUERY_PORT:-9877}"
VRISING_SERVER_NAME="${VRISING_SERVER_NAME:-V Rising Server}"
VRISING_MAX_PLAYERS="${VRISING_MAX_PLAYERS:-40}"
VRISING_PASSWORD="${VRISING_PASSWORD:-}"
VRISING_SAVE_NAME="${VRISING_SAVE_NAME:-world1}"
VRISING_EXTRA_ARGS="${VRISING_EXTRA_ARGS:-}"

WINEPREFIX="${WINEPREFIX:-${VRISING_DIR}/.wine}"
SETTINGS_DIR="${VRISING_DIR}/VRisingServer_Data/StreamingAssets/Settings"
HOST_SETTINGS="${SETTINGS_DIR}/ServerHostSettings.json"

server_bin() {
    find "${VRISING_DIR}" -maxdepth 2 -name 'VRisingServer.exe' -print -quit 2>/dev/null
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
        if [ -n "$(find "${alt_dir}" -maxdepth 2 -name 'VRisingServer.exe' -print -quit 2>/dev/null)" ]; then
            echo "--- Moving server files from ${alt_dir} to ${VRISING_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${VRISING_DIR}/${base}" ]; then
                    mv "${item}" "${VRISING_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/vrising/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

install_server() {
    echo "--- Installing V Rising dedicated server (App ${VRISING_APP_ID}) ---"
    mkdir -p "${VRISING_DIR}"
    steam_cleanup_incomplete_install "${VRISING_DIR}" "${VRISING_APP_ID}" "$(server_bin)"
    steam_prepare_install_dir "${VRISING_DIR}"

    local status=0
    steamcmd_invoke windows "${VRISING_DIR}" \
        +@sSteamCmdForcePlatformBitness 64 \
        +app_update "${VRISING_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "V Rising server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${VRISING_APP_ID}" "V Rising"
        exit 1
    fi

    relocate_install_if_needed

    if ! server_present; then
        echo "V Rising server install failed: VRisingServer.exe not found." >&2
        exit 1
    fi
}

write_host_settings() {
    if [ -f "${HOST_SETTINGS}" ]; then
        return
    fi
    echo "--- Writing default ServerHostSettings.json ---"
    mkdir -p "${SETTINGS_DIR}"
    cat > "${HOST_SETTINGS}" <<EOF
{
  "Name": "${VRISING_SERVER_NAME}",
  "Port": ${VRISING_PORT},
  "QueryPort": ${VRISING_QUERY_PORT},
  "MaxConnectedUsers": ${VRISING_MAX_PLAYERS},
  "MaxConnectedAdmins": 4,
  "ServerFps": 30,
  "SaveName": "${VRISING_SAVE_NAME}",
  "Password": "${VRISING_PASSWORD}",
  "ListOnSteam": true,
  "ListOnEOS": true
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

if ! server_present || [ "${VRISING_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

SERVER_BIN="$(server_bin)"
printf '%s\n' "${VRISING_STEAM_APP_ID}" > "${VRISING_DIR}/steam_appid.txt"
write_host_settings
init_wine

cd "$(dirname "${SERVER_BIN}")"

args=()

# shellcheck disable=SC2206
if [ -n "${VRISING_EXTRA_ARGS}" ]; then
    extra=( ${VRISING_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting V Rising dedicated server on UDP ${VRISING_PORT} ---"
exec xvfb-run -a wine "$(basename "${SERVER_BIN}")" "${args[@]}"
