#!/bin/bash
set -eu

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
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
    mkdir -p "${PALWORLD_DIR}/steamapps"
    cat > "${PALWORLD_DIR}/steamapps/libraryfolders.vdf" <<EOF
"LibraryFolders"
{
    "0" "${PALWORLD_DIR}"
}
EOF
}

cleanup_incomplete_install() {
    if [ -d "${PALWORLD_DIR}/steamapps" ] && ! server_present; then
        echo "--- Removing incomplete Steam install state from ${PALWORLD_DIR} ---"
        rm -rf "${PALWORLD_DIR}/steamapps" "${PALWORLD_DIR}/package"
    fi
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

    local steam_login="${STEAM_USERNAME}"
    if [ -n "${STEAM_PASSWORD}" ]; then
        steam_login="${steam_login} ${STEAM_PASSWORD}"
    fi
    export LD_LIBRARY_PATH="${STEAM_DIR}/linux32:${LD_LIBRARY_PATH:-}"
    local status=0
    while true; do
        # shellcheck disable=SC2086
        "${STEAM_DIR}/linux32/steamcmd" \
            +@sSteamCmdForcePlatformType linux \
            +force_install_dir "${PALWORLD_DIR}" \
            +login ${steam_login} \
            +app_update "${PALWORLD_APP_ID}" validate \
            +quit
        status=$?
        if [ "${status}" -ne 42 ]; then
            break
        fi
    done
    if [ "${status}" -ne 0 ]; then
        echo "Palworld server install failed with exit code ${status}" >&2
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
