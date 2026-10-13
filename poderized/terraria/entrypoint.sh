#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
TERRARIA_APP_ID="${TERRARIA_APP_ID:-105600}"
TERRARIA_FORCE_UPDATE="${TERRARIA_FORCE_UPDATE:-false}"

WORLD_NAME="${WORLD_NAME:-world}"
WORLD_PATH="${WORLD_PATH:-Worlds}"
SERVER_PORT="${SERVER_PORT:-7777}"
MAX_PLAYERS="${MAX_PLAYERS:-8}"
SERVER_PASSWORD="${SERVER_PASSWORD:-}"
MOTD="${MOTD:-Welcome}"
DIFFICULTY="${DIFFICULTY:-0}"
TERRARIA_EXTRA_ARGS="${TERRARIA_EXTRA_ARGS:-}"

SERVER_BINARY="${TERRARIA_DIR}/Linux/TerrariaServer.bin.x86_64"
CONFIG_FILE="${TERRARIA_DIR}/serverconfig.txt"

server_binary_present() {
    [ -f "${SERVER_BINARY}" ]
}

prepare_steam_install_dir() {
    steam_prepare_install_dir "${TERRARIA_DIR}"
}

cleanup_incomplete_install() {
    steam_cleanup_incomplete_install "${TERRARIA_DIR}" "${TERRARIA_APP_ID}" "${SERVER_BINARY}"
}

relocate_install_if_needed() {
    if server_binary_present; then
        return
    fi

    local alt_dir=""
    while IFS= read -r alt_dir; do
        if [ -f "${alt_dir}/Linux/TerrariaServer.bin.x86_64" ]; then
            echo "--- Moving server files from ${alt_dir} to ${TERRARIA_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${TERRARIA_DIR}/${base}" ]; then
                    mv "${item}" "${TERRARIA_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/terraria/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

install_server() {
    echo "--- Installing Terraria dedicated server (App ${TERRARIA_APP_ID}) ---"
    mkdir -p "${TERRARIA_DIR}"
    cleanup_incomplete_install
    prepare_steam_install_dir

    local status=0
    steamcmd_install_linux_app "${TERRARIA_DIR}" "${TERRARIA_APP_ID}" \
        +app_update "${TERRARIA_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "Terraria server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${TERRARIA_APP_ID}" "Terraria"
        exit 1
    fi

    relocate_install_if_needed

    if ! server_binary_present; then
        echo "Terraria server install failed: ${SERVER_BINARY} not found." >&2
        find "${TERRARIA_DIR}" -maxdepth 3 -type f 2>/dev/null | head -50 >&2 || true
        exit 1
    fi

    chmod +x "${SERVER_BINARY}"
}

write_server_config() {
    if [ -f "${CONFIG_FILE}" ]; then
        return
    fi
    echo "--- Writing default serverconfig.txt ---"
    mkdir -p "${TERRARIA_DIR}/${WORLD_PATH}"
    cat > "${CONFIG_FILE}" <<EOF
world=${WORLD_PATH}/${WORLD_NAME}
port=${SERVER_PORT}
password=${SERVER_PASSWORD}
maxplayers=${MAX_PLAYERS}
motd=${MOTD}
difficulty=${DIFFICULTY}
worldpath=${WORLD_PATH}/
autocreate=1
EOF
}

if ! server_binary_present || [ "${TERRARIA_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

write_server_config

cd "${TERRARIA_DIR}"

echo "--- Starting Terraria server on TCP ${SERVER_PORT} ---"
# shellcheck disable=SC2086
exec "${SERVER_BINARY}" -config "${CONFIG_FILE}" ${TERRARIA_EXTRA_ARGS}
