#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
VEIN_APP_ID="${VEIN_APP_ID:-2131400}"
VEIN_FORCE_UPDATE="${VEIN_FORCE_UPDATE:-false}"

VEIN_PORT="${VEIN_PORT:-7777}"
VEIN_QUERY_PORT="${VEIN_QUERY_PORT:-27015}"
VEIN_MAX_PLAYERS="${VEIN_MAX_PLAYERS:-16}"
VEIN_EXTRA_ARGS="${VEIN_EXTRA_ARGS:-}"

WINEPREFIX="${WINEPREFIX:-${VEIN_DIR}/.wine}"

server_bin() {
    find "${VEIN_DIR}" -maxdepth 5 -iname 'VeinServer*.exe' -print -quit 2>/dev/null
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
        if [ -n "$(find "${alt_dir}" -maxdepth 5 -iname 'VeinServer*.exe' -print -quit 2>/dev/null)" ]; then
            echo "--- Moving server files from ${alt_dir} to ${VEIN_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${VEIN_DIR}/${base}" ]; then
                    mv "${item}" "${VEIN_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/vein/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

install_server() {
    echo "--- Installing VEIN dedicated server (App ${VEIN_APP_ID}) ---"
    mkdir -p "${VEIN_DIR}"
    steam_cleanup_incomplete_install "${VEIN_DIR}" "${VEIN_APP_ID}" "$(server_bin)"
    steam_prepare_install_dir "${VEIN_DIR}"

    local status=0
    steamcmd_invoke windows "${VEIN_DIR}" \
        +@sSteamCmdForcePlatformBitness 64 \
        +app_update "${VEIN_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "VEIN server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${VEIN_APP_ID}" "VEIN"
        exit 1
    fi

    relocate_install_if_needed

    if ! server_present; then
        echo "VEIN server install failed: VeinServer executable not found." >&2
        exit 1
    fi
}

init_wine() {
    if [ ! -d "${WINEPREFIX}/drive_c" ]; then
        echo "--- Initializing Wine prefix at ${WINEPREFIX} ---"
        wineboot --init
        wineserver --wait
    fi
}

if ! server_present || [ "${VEIN_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

SERVER_BIN="$(server_bin)"
init_wine

cd "$(dirname "${SERVER_BIN}")"

args=(
    -log
    "-port=${VEIN_PORT}"
    "-QueryPort=${VEIN_QUERY_PORT}"
    "-MaxPlayers=${VEIN_MAX_PLAYERS}"
)

# shellcheck disable=SC2206
if [ -n "${VEIN_EXTRA_ARGS}" ]; then
    extra=( ${VEIN_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting VEIN dedicated server on UDP ${VEIN_PORT} ---"
exec xvfb-run -a wine "$(basename "${SERVER_BIN}")" "${args[@]}"
