#!/bin/bash
set -eu

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
GB_APP_ID="${GB_APP_ID:-476400}"
GB_STEAM_APP_ID="${GB_STEAM_APP_ID:-16900}"
GB_FORCE_UPDATE="${GB_FORCE_UPDATE:-false}"

GB_PORT="${GB_PORT:-7777}"
GB_QUERY_PORT="${GB_QUERY_PORT:-27015}"
GB_MULTIHOME="${GB_MULTIHOME:-0.0.0.0}"
GB_MAX_PLAYERS="${GB_MAX_PLAYERS:-8}"
GB_MAX_AI="${GB_MAX_AI:-30}"
GB_MAP="${GB_MAP:-}"
GB_MISSION="${GB_MISSION:-}"
GB_EXTRA_ARGS="${GB_EXTRA_ARGS:-}"

SERVER_BIN="${GB_INSTALL_DIR}/GroundBranch/Binaries/Win64/GroundBranchServer-Win64-Shipping.exe"
SERVER_CONFIG_DIR="${GB_INSTALL_DIR}/GroundBranch/ServerConfig"

install_server() {
    echo "--- Installing Ground Branch dedicated server (App ${GB_APP_ID}) ---"
    local steam_login="${STEAM_USERNAME}"
    if [ -n "${STEAM_PASSWORD}" ]; then
        steam_login="${steam_login} ${STEAM_PASSWORD}"
    fi
    export LD_LIBRARY_PATH="${STEAM_DIR}/linux32:${LD_LIBRARY_PATH:-}"
    local status=0
    while true; do
        # shellcheck disable=SC2086
        "${STEAM_DIR}/steamcmd.sh" \
            +@sSteamCmdForcePlatformType windows \
            +@sSteamCmdForcePlatformBitness 64 \
            +force_install_dir "${GB_INSTALL_DIR}" \
            +login ${steam_login} \
            +app_update "${GB_APP_ID}" validate \
            +quit
        status=$?
        if [ "${status}" -ne 42 ]; then
            break
        fi
    done
    if [ "${status}" -ne 0 ]; then
        echo "Ground Branch server install failed with exit code ${status}" >&2
        exit 1
    fi
    if [ ! -f "${SERVER_BIN}" ]; then
        echo "Ground Branch server install failed: ${SERVER_BIN} not found" >&2
        exit 1
    fi
}

init_wine() {
    if [ ! -d "${WINEPREFIX}/drive_c" ]; then
        echo "--- Initializing Wine prefix ---"
        wineboot --init
        wineserver --wait
    fi
}

build_server_args() {
    local args=""
    if [ -n "${GB_MAP}" ]; then
        args="${GB_MAP}"
        if [ -n "${GB_MISSION}" ]; then
            args="${args}?Mission=${GB_MISSION}"
        fi
        args="${args}?MaxPlayers=${GB_MAX_PLAYERS}?MaxAI=${GB_MAX_AI}"
    else
        args="?MaxPlayers=${GB_MAX_PLAYERS}?MaxAI=${GB_MAX_AI}"
    fi
    printf '%s' "${args}"
}

if [ ! -f "${SERVER_BIN}" ] || [ "${GB_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

printf '%s\n' "${GB_STEAM_APP_ID}" > "${GB_INSTALL_DIR}/steam_appid.txt"
mkdir -p "${SERVER_CONFIG_DIR}"

init_wine

cd "${GB_INSTALL_DIR}"

server_args="$(build_server_args)"

echo "--- Starting Ground Branch server on port ${GB_PORT} ---"
# shellcheck disable=SC2086
exec wine "${SERVER_BIN}" \
    "${server_args}" \
    MultiHome="${GB_MULTIHOME}" \
    Port="${GB_PORT}" \
    QueryPort="${GB_QUERY_PORT}" \
    -log -nohomedir -stdout -FullStdOutLogOutput \
    ${GB_EXTRA_ARGS}
