#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
PALWORLD_APP_ID="${PALWORLD_APP_ID:-2394010}"
PALWORLD_FORCE_UPDATE="${PALWORLD_FORCE_UPDATE:-false}"

PALWORLD_PORT="${PALWORLD_PORT:-8211}"
PALWORLD_PLAYERS="${PALWORLD_PLAYERS:-32}"
PALWORLD_EXTRA_ARGS="${PALWORLD_EXTRA_ARGS:-}"

PAL_SERVER_SCRIPT="${PALWORLD_DIR}/PalServer.sh"

server_present() {
    [ -f "${PAL_SERVER_SCRIPT}" ]
}

prepare_steam_install_dir() {
    steam_prepare_install_dir "${PALWORLD_DIR}"
}

cleanup_incomplete_install() {
    steam_cleanup_incomplete_install "${PALWORLD_DIR}" "${PALWORLD_APP_ID}" "${PAL_SERVER_SCRIPT}"
}

relocate_install_if_needed() {
    if server_present; then
        return
    fi

    local alt_dir=""
    while IFS= read -r alt_dir; do
        if [ -f "${alt_dir}/PalServer.sh" ]; then
            echo "--- Moving server files from ${alt_dir} to ${PALWORLD_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${PALWORLD_DIR}/${base}" ]; then
                    mv "${item}" "${PALWORLD_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/palworld/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

install_server() {
    echo "--- Installing Palworld dedicated server (App ${PALWORLD_APP_ID}) ---"
    mkdir -p "${PALWORLD_DIR}"
    cleanup_incomplete_install
    prepare_steam_install_dir

    local status=0
    steamcmd_install_linux_app "${PALWORLD_DIR}" "${PALWORLD_APP_ID}" \
        +app_update "${PALWORLD_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "Palworld server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${PALWORLD_APP_ID}" "Palworld"
        exit 1
    fi

    relocate_install_if_needed

    if ! server_present; then
        echo "Palworld server install failed: ${PAL_SERVER_SCRIPT} not found." >&2
        ls -la "${PALWORLD_DIR}" >&2 || true
        exit 1
    fi

    chmod +x "${PAL_SERVER_SCRIPT}"
}

if ! server_present || [ "${PALWORLD_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

cd "${PALWORLD_DIR}"

pal_args=(
    -port="${PALWORLD_PORT}"
    -players="${PALWORLD_PLAYERS}"
    -useperfthreads
    -NoAsyncLoadingThread
    -UseMultithreadForDS
)

# shellcheck disable=SC2206
if [ -n "${PALWORLD_EXTRA_ARGS}" ]; then
    extra=( ${PALWORLD_EXTRA_ARGS} )
    pal_args+=("${extra[@]}")
fi

echo "--- Starting Palworld dedicated server on UDP ${PALWORLD_PORT} ---"
exec bash "${PAL_SERVER_SCRIPT}" "${pal_args[@]}"
