#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
ICARUS_APP_ID="${ICARUS_APP_ID:-2089300}"
ICARUS_STEAM_APP_ID="${ICARUS_STEAM_APP_ID:-1149460}"
ICARUS_FORCE_UPDATE="${ICARUS_FORCE_UPDATE:-false}"

ICARUS_PORT="${ICARUS_PORT:-17777}"
ICARUS_QUERY_PORT="${ICARUS_QUERY_PORT:-27015}"
ICARUS_GAME_MODE="${ICARUS_GAME_MODE:-Prospect}"
ICARUS_SESSION_NAME="${ICARUS_SESSION_NAME:-Icarus Server}"
ICARUS_MAX_PLAYERS="${ICARUS_MAX_PLAYERS:-8}"
ICARUS_ADMIN_PASSWORD="${ICARUS_ADMIN_PASSWORD:-}"
ICARUS_EXTRA_ARGS="${ICARUS_EXTRA_ARGS:-}"

WINEPREFIX="${WINEPREFIX:-${ICARUS_DIR}/.wine}"

server_bin() {
    find "${ICARUS_DIR}" -name 'IcarusServer-Win64-Shipping.exe' -print -quit 2>/dev/null
}

server_present() {
    [ -n "$(server_bin)" ]
}

prepare_steam_install_dir() {
    steam_prepare_install_dir "${ICARUS_DIR}"
}

cleanup_incomplete_install() {
    local ready=""
    ready="$(server_bin)"
    steam_cleanup_incomplete_install "${ICARUS_DIR}" "${ICARUS_APP_ID}" "${ready}"
}

relocate_install_if_needed() {
    if server_present; then
        return
    fi

    local alt_dir=""
    while IFS= read -r alt_dir; do
        if [ -n "$(find "${alt_dir}" -name 'IcarusServer-Win64-Shipping.exe' -print -quit 2>/dev/null)" ]; then
            echo "--- Moving server files from ${alt_dir} to ${ICARUS_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${ICARUS_DIR}/${base}" ]; then
                    mv "${item}" "${ICARUS_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/icarus/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

install_server() {
    echo "--- Installing Icarus dedicated server (App ${ICARUS_APP_ID}) ---"
    mkdir -p "${ICARUS_DIR}"
    cleanup_incomplete_install
    prepare_steam_install_dir

    local status=0
    steamcmd_invoke windows "${ICARUS_DIR}" \
        +@sSteamCmdForcePlatformBitness 64 \
        +app_update "${ICARUS_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "Icarus server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${ICARUS_APP_ID}" "Icarus"
        exit 1
    fi

    relocate_install_if_needed

    if ! server_present; then
        echo "Icarus server install failed: IcarusServer-Win64-Shipping.exe not found." >&2
        find "${ICARUS_DIR}" -maxdepth 4 -type f -name '*.exe' 2>/dev/null | head -20 >&2 || true
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

if ! server_present || [ "${ICARUS_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

SERVER_BIN="$(server_bin)"
printf '%s\n' "${ICARUS_STEAM_APP_ID}" > "${ICARUS_DIR}/steam_appid.txt"

init_wine

cd "$(dirname "${SERVER_BIN}")"

args=(
    -log
    "-Port=${ICARUS_PORT}"
    "-QueryPort=${ICARUS_QUERY_PORT}"
    "-GameMode=${ICARUS_GAME_MODE}"
    "-SessionName=${ICARUS_SESSION_NAME}"
    "-MaxPlayers=${ICARUS_MAX_PLAYERS}"
    "-SteamServerName=${ICARUS_SESSION_NAME}"
)

if [ -n "${ICARUS_ADMIN_PASSWORD}" ]; then
    args+=("-AdminPassword=${ICARUS_ADMIN_PASSWORD}")
fi

# shellcheck disable=SC2206
if [ -n "${ICARUS_EXTRA_ARGS}" ]; then
    extra=( ${ICARUS_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting Icarus dedicated server on port ${ICARUS_PORT} ---"
exec wine "$(basename "${SERVER_BIN}")" "${args[@]}"
