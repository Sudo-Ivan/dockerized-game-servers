#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
WINDROSE_APP_ID="${WINDROSE_APP_ID:-4129620}"
WINDROSE_FORCE_UPDATE="${WINDROSE_FORCE_UPDATE:-false}"

WINDROSE_SERVER_NAME="${WINDROSE_SERVER_NAME:-Windrose Server}"
WINDROSE_DIRECT_PORT="${WINDROSE_DIRECT_PORT:-7777}"
WINDROSE_MAX_PLAYERS="${WINDROSE_MAX_PLAYERS:-4}"
WINDROSE_PASSWORD="${WINDROSE_PASSWORD:-}"
WINDROSE_EXTRA_ARGS="${WINDROSE_EXTRA_ARGS:-}"

WINEPREFIX="${WINEPREFIX:-${WINDROSE_DIR}/.wine}"
SERVER_DESC="${WINDROSE_DIR}/R5/ServerDescription.json"

server_bin() {
    find "${WINDROSE_DIR}" -maxdepth 3 -name 'WindroseServer.exe' -print -quit 2>/dev/null
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
        if [ -n "$(find "${alt_dir}" -maxdepth 3 -name 'WindroseServer.exe' -print -quit 2>/dev/null)" ]; then
            echo "--- Moving server files from ${alt_dir} to ${WINDROSE_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${WINDROSE_DIR}/${base}" ]; then
                    mv "${item}" "${WINDROSE_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/windrose/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

install_server() {
    echo "--- Installing Windrose dedicated server (App ${WINDROSE_APP_ID}) ---"
    mkdir -p "${WINDROSE_DIR}"
    steam_cleanup_incomplete_install "${WINDROSE_DIR}" "${WINDROSE_APP_ID}" "$(server_bin)"
    steam_prepare_install_dir "${WINDROSE_DIR}"

    local status=0
    steamcmd_invoke windows "${WINDROSE_DIR}" \
        +@sSteamCmdForcePlatformBitness 64 \
        +app_update "${WINDROSE_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "Windrose server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${WINDROSE_APP_ID}" "Windrose"
        exit 1
    fi

    relocate_install_if_needed

    if ! server_present; then
        echo "Windrose server install failed: WindroseServer.exe not found." >&2
        exit 1
    fi
}

write_server_description() {
    if [ -f "${SERVER_DESC}" ]; then
        return
    fi
    echo "--- Writing default R5/ServerDescription.json ---"
    mkdir -p "$(dirname "${SERVER_DESC}")"
    cat > "${SERVER_DESC}" <<EOF
{
  "ServerName": "${WINDROSE_SERVER_NAME}",
  "MaxPlayers": ${WINDROSE_MAX_PLAYERS},
  "Password": "${WINDROSE_PASSWORD}",
  "UseDirectConnection": true,
  "DirectConnectionServerPort": ${WINDROSE_DIRECT_PORT}
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

if ! server_present || [ "${WINDROSE_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

SERVER_BIN="$(server_bin)"
write_server_description
init_wine

cd "$(dirname "${SERVER_BIN}")"

args=()

# shellcheck disable=SC2206
if [ -n "${WINDROSE_EXTRA_ARGS}" ]; then
    extra=( ${WINDROSE_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting Windrose dedicated server on ${WINDROSE_DIRECT_PORT} TCP/UDP ---"
exec xvfb-run -a wine "$(basename "${SERVER_BIN}")" "${args[@]}"
