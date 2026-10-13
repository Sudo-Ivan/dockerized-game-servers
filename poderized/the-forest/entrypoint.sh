#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
FOREST_APP_ID="${FOREST_APP_ID:-556450}"
FOREST_FORCE_UPDATE="${FOREST_FORCE_UPDATE:-false}"

FOREST_IP="${FOREST_IP:-0.0.0.0}"
FOREST_STEAM_PORT="${FOREST_STEAM_PORT:-8766}"
FOREST_GAME_PORT="${FOREST_GAME_PORT:-27015}"
FOREST_QUERY_PORT="${FOREST_QUERY_PORT:-27016}"
FOREST_SERVER_NAME="${FOREST_SERVER_NAME:-The Forest Dedicated Server}"
FOREST_MAX_PLAYERS="${FOREST_MAX_PLAYERS:-8}"
FOREST_PASSWORD="${FOREST_PASSWORD:-}"
FOREST_ADMIN_PASSWORD="${FOREST_ADMIN_PASSWORD:-}"
FOREST_STEAM_ACCOUNT="${FOREST_STEAM_ACCOUNT:-}"
FOREST_DIFFICULTY="${FOREST_DIFFICULTY:-Normal}"
FOREST_INIT_TYPE="${FOREST_INIT_TYPE:-Continue}"
FOREST_SLOT="${FOREST_SLOT:-1}"
FOREST_AUTOSAVE_INTERVAL="${FOREST_AUTOSAVE_INTERVAL:-15}"
FOREST_ENABLE_VAC="${FOREST_ENABLE_VAC:-true}"
FOREST_EXTRA_ARGS="${FOREST_EXTRA_ARGS:-}"

# shellcheck disable=SC2153
SERVER_BIN="${FOREST_DIR}/TheForestDedicatedServer"

server_present() {
    [ -f "${SERVER_BIN}" ]
}

prepare_steam_install_dir() {
    steam_prepare_install_dir "${FOREST_DIR}"
}

cleanup_incomplete_install() {
    steam_cleanup_incomplete_install "${FOREST_DIR}" "${FOREST_APP_ID}" "${SERVER_BIN}"
}

relocate_install_if_needed() {
    if server_present; then
        return
    fi

    local alt_dir=""
    while IFS= read -r alt_dir; do
        if [ -f "${alt_dir}/TheForestDedicatedServer" ]; then
            echo "--- Moving server files from ${alt_dir} to ${FOREST_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${FOREST_DIR}/${base}" ]; then
                    mv "${item}" "${FOREST_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/theforest/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

install_server() {
    echo "--- Installing The Forest dedicated server (App ${FOREST_APP_ID}) ---"
    mkdir -p "${FOREST_DIR}"
    cleanup_incomplete_install
    prepare_steam_install_dir

    local status=0
    steamcmd_install_linux_app "${FOREST_DIR}" "${FOREST_APP_ID}" \
        +app_update "${FOREST_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "The Forest server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${FOREST_APP_ID}" "The Forest"
        exit 1
    fi

    relocate_install_if_needed

    if ! server_present; then
        echo "The Forest server install failed: ${SERVER_BIN} not found." >&2
        find "${FOREST_DIR}" -maxdepth 3 -type f 2>/dev/null | head -50 >&2 || true
        exit 1
    fi

    chmod +x "${SERVER_BIN}"
}

if ! server_present || [ "${FOREST_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

export HOME="${FOREST_DIR}/home"
mkdir -p "${HOME}"

cd "${FOREST_DIR}"

args=(
    -batchmode
    -nographics
    -serverip "${FOREST_IP}"
    -serversteamport "${FOREST_STEAM_PORT}"
    -servergameport "${FOREST_GAME_PORT}"
    -serverqueryport "${FOREST_QUERY_PORT}"
    -servername "${FOREST_SERVER_NAME}"
    -serverplayers "${FOREST_MAX_PLAYERS}"
    -difficulty "${FOREST_DIFFICULTY}"
    -inittype "${FOREST_INIT_TYPE}"
    -slot "${FOREST_SLOT}"
    -serverautosaveinterval "${FOREST_AUTOSAVE_INTERVAL}"
)

if [ -n "${FOREST_PASSWORD}" ]; then
    args+=(-serverpassword "${FOREST_PASSWORD}")
fi

if [ -n "${FOREST_ADMIN_PASSWORD}" ]; then
    args+=(-serverpassword_admin "${FOREST_ADMIN_PASSWORD}")
fi

if [ -n "${FOREST_STEAM_ACCOUNT}" ]; then
    args+=(-serversteamaccount "${FOREST_STEAM_ACCOUNT}")
fi

if [ "${FOREST_ENABLE_VAC}" = "true" ]; then
    args+=(-enableVAC)
fi

# shellcheck disable=SC2206
if [ -n "${FOREST_EXTRA_ARGS}" ]; then
    extra=( ${FOREST_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting The Forest dedicated server on UDP ${FOREST_GAME_PORT} ---"
exec "${SERVER_BIN}" "${args[@]}"
