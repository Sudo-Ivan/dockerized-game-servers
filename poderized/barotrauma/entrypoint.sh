#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
BAROTRAUMA_APP_ID="${BAROTRAUMA_APP_ID:-1026340}"
BAROTRAUMA_FORCE_UPDATE="${BAROTRAUMA_FORCE_UPDATE:-false}"
BAROTRAUMA_EXTRA_ARGS="${BAROTRAUMA_EXTRA_ARGS:-}"

SERVER_BIN="${BAROTRAUMA_DIR}/DedicatedServer"

server_present() {
    [ -f "${SERVER_BIN}" ]
}

link_steamclient() {
    local sdk_dir="/home/barotrauma/.steam/sdk64"
    local client_src="${STEAM_DIR}/linux64/steamclient.so"
    if [ -f "${client_src}" ]; then
        mkdir -p "${sdk_dir}"
        ln -sf "${client_src}" "${sdk_dir}/steamclient.so"
    fi
}

install_server() {
    echo "--- Installing Barotrauma dedicated server (App ${BAROTRAUMA_APP_ID}) ---"
    mkdir -p "${BAROTRAUMA_DIR}"
    steam_cleanup_incomplete_install "${BAROTRAUMA_DIR}" "${BAROTRAUMA_APP_ID}" "${SERVER_BIN}"
    steam_prepare_install_dir "${BAROTRAUMA_DIR}"

    local status=0
    steamcmd_install_linux_app "${BAROTRAUMA_DIR}" "${BAROTRAUMA_APP_ID}" \
        +app_update "${BAROTRAUMA_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "Barotrauma server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${BAROTRAUMA_APP_ID}" "Barotrauma"
        exit 1
    fi

    if ! server_present; then
        local alt_dir=""
        while IFS= read -r alt_dir; do
            if [ -f "${alt_dir}/DedicatedServer" ]; then
                echo "--- Moving server files from ${alt_dir} to ${BAROTRAUMA_DIR} ---"
                shopt -s dotglob nullglob
                local item base
                for item in "${alt_dir}"/*; do
                    base="$(basename "${item}")"
                    if [ ! -e "${BAROTRAUMA_DIR}/${base}" ]; then
                        mv "${item}" "${BAROTRAUMA_DIR}/"
                    fi
                done
                shopt -u dotglob nullglob
                break
            fi
        done < <(find /home/barotrauma/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
    fi

    if ! server_present; then
        echo "Barotrauma server install failed: ${SERVER_BIN} not found." >&2
        exit 1
    fi

    chmod +x "${SERVER_BIN}"
}

if ! server_present || [ "${BAROTRAUMA_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

link_steamclient

cd "${BAROTRAUMA_DIR}"

export LD_LIBRARY_PATH="${BAROTRAUMA_DIR}/linux64:${LD_LIBRARY_PATH:-}"

echo "--- Starting Barotrauma dedicated server ---"
# shellcheck disable=SC2086
exec "${SERVER_BIN}" ${BAROTRAUMA_EXTRA_ARGS}
