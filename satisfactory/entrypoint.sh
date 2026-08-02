#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
SATISFACTORY_APP_ID="${SATISFACTORY_APP_ID:-1690800}"
SATISFACTORY_FORCE_UPDATE="${SATISFACTORY_FORCE_UPDATE:-false}"

SATISFACTORY_PORT="${SATISFACTORY_PORT:-7777}"
SATISFACTORY_RELIABLE_PORT="${SATISFACTORY_RELIABLE_PORT:-8888}"
SATISFACTORY_EXTRA_ARGS="${SATISFACTORY_EXTRA_ARGS:-}"

FACTORY_SCRIPT="${SATISFACTORY_DIR}/FactoryServer.sh"

server_present() {
    [ -f "${FACTORY_SCRIPT}" ]
}

relocate_install_if_needed() {
    if server_present; then
        return
    fi

    local alt_dir=""
    while IFS= read -r alt_dir; do
        if [ -f "${alt_dir}/FactoryServer.sh" ]; then
            echo "--- Moving server files from ${alt_dir} to ${SATISFACTORY_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${SATISFACTORY_DIR}/${base}" ]; then
                    mv "${item}" "${SATISFACTORY_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/satisfactory/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

install_server() {
    echo "--- Installing Satisfactory dedicated server (App ${SATISFACTORY_APP_ID}) ---"
    mkdir -p "${SATISFACTORY_DIR}"
    steam_cleanup_incomplete_install "${SATISFACTORY_DIR}" "${SATISFACTORY_APP_ID}" "${FACTORY_SCRIPT}"
    steam_prepare_install_dir "${SATISFACTORY_DIR}"

    local status=0
    steamcmd_install_linux_app "${SATISFACTORY_DIR}" "${SATISFACTORY_APP_ID}" \
        +app_update "${SATISFACTORY_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "Satisfactory server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${SATISFACTORY_APP_ID}" "Satisfactory"
        exit 1
    fi

    relocate_install_if_needed

    if ! server_present; then
        echo "Satisfactory server install failed: ${FACTORY_SCRIPT} not found." >&2
        exit 1
    fi

    chmod +x "${FACTORY_SCRIPT}"
}

if ! server_present || [ "${SATISFACTORY_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

cd "${SATISFACTORY_DIR}"

args=(
    -Port="${SATISFACTORY_PORT}"
    -ReliablePort="${SATISFACTORY_RELIABLE_PORT}"
)

# shellcheck disable=SC2206
if [ -n "${SATISFACTORY_EXTRA_ARGS}" ]; then
    extra=( ${SATISFACTORY_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting Satisfactory dedicated server on ${SATISFACTORY_PORT} TCP/UDP and ${SATISFACTORY_RELIABLE_PORT} TCP ---"
export LD_LIBRARY_PATH="${SATISFACTORY_DIR}/linux64:${LD_LIBRARY_PATH:-}"
exec bash "${FACTORY_SCRIPT}" "${args[@]}"
