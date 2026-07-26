#!/bin/bash
set -eu

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
CK_APP_ID="${CK_APP_ID:-1963720}"
CK_STEAMWORKS_APP_ID="${CK_STEAMWORKS_APP_ID:-1007}"
CK_FORCE_UPDATE="${CK_FORCE_UPDATE:-false}"

WORLD_INDEX="${WORLD_INDEX:-0}"
WORLD_NAME="${WORLD_NAME:-Core Keeper Server}"
WORLD_SEED="${WORLD_SEED:-}"
HASHED_WORLD_SEED="${HASHED_WORLD_SEED:-}"
WORLD_MODE="${WORLD_MODE:-0}"
GAME_ID="${GAME_ID:-}"
MAX_PLAYERS="${MAX_PLAYERS:-10}"
SEASON="${SEASON:-}"
SERVER_IP="${SERVER_IP:-}"
SERVER_PORT="${SERVER_PORT:-}"
PASSWORD="${PASSWORD:-}"
ACTIVATE_CONTENT="${ACTIVATE_CONTENT:-}"
ACTIVATE_ALL_CONTENT="${ACTIVATE_ALL_CONTENT:-false}"
ALLOW_ONLY_PLATFORM="${ALLOW_ONLY_PLATFORM:-}"
CK_EXTRA_ARGS="${CK_EXTRA_ARGS:-}"

SERVER_BIN="${CK_INSTALL_DIR}/CoreKeeperServer"
xvfbpid=""
ckpid=""

add_param() {
    local name="$1"
    local value="$2"
    if [ -n "${value}" ]; then
        params+=("${name}" "${value}")
    fi
}

cleanup() {
    if [ -n "${ckpid}" ] && kill -0 "${ckpid}" 2>/dev/null; then
        kill "${ckpid}" 2>/dev/null || true
        wait "${ckpid}" 2>/dev/null || true
    fi
    if [ -n "${xvfbpid}" ] && kill -0 "${xvfbpid}" 2>/dev/null; then
        kill "${xvfbpid}" 2>/dev/null || true
        wait "${xvfbpid}" 2>/dev/null || true
    fi
}

trap cleanup EXIT INT TERM

install_server() {
    echo "--- Installing Core Keeper dedicated server (App ${CK_APP_ID}) ---"
    local steam_login="${STEAM_USERNAME}"
    if [ -n "${STEAM_PASSWORD}" ]; then
        steam_login="${steam_login} ${STEAM_PASSWORD}"
    fi
    mkdir -p "${CK_INSTALL_DIR}"
    export LD_LIBRARY_PATH="${STEAM_DIR}/linux32:${LD_LIBRARY_PATH:-}"
    local status=0
    while true; do
        "${STEAM_DIR}/linux32/steamcmd" \
            +@sSteamCmdForcePlatformType linux \
            +@sSteamCmdForcePlatformBitness 64 \
            +force_install_dir "${CK_INSTALL_DIR}" \
            +login ${steam_login} \
            +app_update "${CK_STEAMWORKS_APP_ID}" validate \
            +app_update "${CK_APP_ID}" validate \
            +quit
        status=$?
        if [ "${status}" -ne 42 ]; then
            break
        fi
    done
    if [ "${status}" -ne 0 ]; then
        echo "Core Keeper server install failed with exit code ${status}" >&2
        exit 1
    fi
    if [ ! -x "${SERVER_BIN}" ] && [ -f "${SERVER_BIN}" ]; then
        chmod +x "${SERVER_BIN}"
    fi
    if [ ! -f "${SERVER_BIN}" ]; then
        echo "Core Keeper server install failed: ${SERVER_BIN} not found" >&2
        exit 1
    fi
}

if [ ! -f "${SERVER_BIN}" ] || [ "${CK_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

mkdir -p "${CK_DATA_DIR}" "${CK_INSTALL_DIR}/logs"
rm -f /tmp/.X99-lock \
    "${CK_INSTALL_DIR}/GameID.txt" \
    "${CK_INSTALL_DIR}/GameInfo.txt"

logfile="${CK_INSTALL_DIR}/logs/$(date '+%Y-%m-%d_%H-%M-%S').log"
touch "${logfile}"

params=(
    "-batchmode"
    "-logfile" "${logfile}"
)

add_param "-world" "${WORLD_INDEX}"
add_param "-worldname" "${WORLD_NAME}"
add_param "-worldseed" "${WORLD_SEED}"
add_param "-worldmode" "${WORLD_MODE}"
add_param "-hashedworldseed" "${HASHED_WORLD_SEED}"
add_param "-gameid" "${GAME_ID}"
add_param "-datapath" "${CK_DATA_DIR}"
add_param "-maxplayers" "${MAX_PLAYERS}"
add_param "-season" "${SEASON}"
add_param "-ip" "${SERVER_IP}"
add_param "-port" "${SERVER_PORT}"
add_param "-activatecontent" "${ACTIVATE_CONTENT}"
add_param "-password" "${PASSWORD}"
add_param "-allowonlyplatform" "${ALLOW_ONLY_PLATFORM}"

if [ "${ACTIVATE_ALL_CONTENT}" = "true" ] || [ "${ACTIVATE_ALL_CONTENT}" = "TRUE" ]; then
    params+=("-activateallcontent")
fi

# shellcheck disable=SC2206
if [ -n "${CK_EXTRA_ARGS}" ]; then
    extra=( ${CK_EXTRA_ARGS} )
    params+=("${extra[@]}")
fi

echo "--- Starting Xvfb ---"
Xvfb :99 -screen 0 1x1x24 -nolisten tcp &
xvfbpid=$!

cd "${CK_INSTALL_DIR}"
echo "--- Starting Core Keeper server ---"
if [ -n "${SERVER_PORT}" ]; then
    echo "Direct connect mode on port ${SERVER_PORT}"
else
    echo "SDR mode (no SERVER_PORT set). Game ID will be written to GameID.txt"
fi

DISPLAY=:99 \
LD_LIBRARY_PATH="${STEAM_DIR}/linux64:${LD_LIBRARY_PATH:-}" \
    ./CoreKeeperServer "${params[@]}" &
ckpid=$!

wait "${ckpid}"
