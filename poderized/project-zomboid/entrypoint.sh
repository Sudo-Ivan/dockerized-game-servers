#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
PZ_APP_ID="${PZ_APP_ID:-380870}"
PZ_FORCE_UPDATE="${PZ_FORCE_UPDATE:-false}"

PZ_SERVER_NAME="${PZ_SERVER_NAME:-servertest}"
PZ_ADMIN_PASSWORD="${PZ_ADMIN_PASSWORD:-changeme}"
PZ_NO_STEAM="${PZ_NO_STEAM:-false}"
PZ_EXTRA_ARGS="${PZ_EXTRA_ARGS:-}"

START_SCRIPT="${PZ_INSTALL_DIR}/start-server.sh"

server_present() {
    [ -f "${START_SCRIPT}" ]
}

prepare_steam_install_dir() {
    steam_prepare_install_dir "${PZ_INSTALL_DIR}"
}

cleanup_incomplete_install() {
    steam_cleanup_incomplete_install "${PZ_INSTALL_DIR}" "${PZ_APP_ID}" "${START_SCRIPT}"
}

relocate_install_if_needed() {
    if server_present; then
        return
    fi

    local alt_dir=""
    while IFS= read -r alt_dir; do
        if [ -f "${alt_dir}/start-server.sh" ]; then
            echo "--- Moving server files from ${alt_dir} to ${PZ_INSTALL_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${PZ_INSTALL_DIR}/${base}" ]; then
                    mv "${item}" "${PZ_INSTALL_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/zomboid/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

install_server() {
    echo "--- Installing Project Zomboid dedicated server (App ${PZ_APP_ID}) ---"
    mkdir -p "${PZ_INSTALL_DIR}" "${PZ_HOME}"
    cleanup_incomplete_install
    prepare_steam_install_dir

    local status=0
    steamcmd_install_linux_app "${PZ_INSTALL_DIR}" "${PZ_APP_ID}" \
        +app_update "${PZ_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "Project Zomboid server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${PZ_APP_ID}" "Project Zomboid"
        exit 1
    fi

    relocate_install_if_needed

    if ! server_present; then
        echo "Project Zomboid server install failed: ${START_SCRIPT} not found." >&2
        ls -la "${PZ_INSTALL_DIR}" >&2 || true
        exit 1
    fi

    if [ ! -x "${START_SCRIPT}" ]; then
        chmod +x "${START_SCRIPT}"
    fi
}

if ! server_present || [ "${PZ_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

export HOME="${PZ_HOME}"
export LD_LIBRARY_PATH="${PZ_INSTALL_DIR}/linux64:${LD_LIBRARY_PATH:-}"

cd "${PZ_INSTALL_DIR}"

args=(
    -servername "${PZ_SERVER_NAME}"
    -adminpassword "${PZ_ADMIN_PASSWORD}"
)

if [ "${PZ_NO_STEAM}" = "true" ] || [ "${PZ_NO_STEAM}" = "TRUE" ] || [ "${PZ_NO_STEAM}" = "1" ]; then
    args+=(-nosteam)
fi

# shellcheck disable=SC2206
if [ -n "${PZ_EXTRA_ARGS}" ]; then
    extra=( ${PZ_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting Project Zomboid server (${PZ_SERVER_NAME}) ---"
echo "--- Saves and config: ${PZ_HOME}/Zomboid/ ---"
exec bash "${START_SCRIPT}" "${args[@]}"
