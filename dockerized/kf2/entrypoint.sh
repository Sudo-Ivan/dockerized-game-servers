#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
KF2_APP_ID="${KF2_APP_ID:-232130}"
STEAMCMD_WINDOWS_WORKAROUND="${STEAMCMD_WINDOWS_WORKAROUND:-full}"
KF2_FORCE_UPDATE="${KF2_FORCE_UPDATE:-false}"

KF2_PORT="${KF2_PORT:-7777}"
KF2_QUERY_PORT="${KF2_QUERY_PORT:-27015}"
KF2_STARTMAP="${KF2_STARTMAP:-kf-bioticslab}"
KF2_EXTRA_ARGS="${KF2_EXTRA_ARGS:-}"

SERVER_BIN="${KF2_DIR}/Binaries/Win64/KFGameSteamServer.bin.x86_64"

server_present() {
    [ -f "${SERVER_BIN}" ]
}

prepare_steam_install_dir() {
    steam_prepare_install_dir "${KF2_DIR}"
}

cleanup_incomplete_install() {
    steam_cleanup_incomplete_install "${KF2_DIR}" "${KF2_APP_ID}" "${SERVER_BIN}"
}

relocate_install_if_needed() {
    if server_present; then
        return
    fi

    local alt_dir=""
    while IFS= read -r alt_dir; do
        if [ -f "${alt_dir}/Binaries/Win64/KFGameSteamServer.bin.x86_64" ]; then
            echo "--- Moving server files from ${alt_dir} to ${KF2_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${KF2_DIR}/${base}" ]; then
                    mv "${item}" "${KF2_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/kf2/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

setup_steam_runtime_libs() {
    mkdir -p "${KF2_DIR}/linux64" "${KF2_DIR}/linux32"
    if [ -f "${STEAM_DIR}/linux64/steamclient.so" ]; then
        cp -f "${STEAM_DIR}/linux64/steamclient.so" "${KF2_DIR}/linux64/" 2>/dev/null || true
    fi
    if [ -f "${STEAM_DIR}/linux32/steamclient.so" ]; then
        cp -f "${STEAM_DIR}/linux32/steamclient.so" "${KF2_DIR}/linux32/" 2>/dev/null || true
    fi
}

install_server() {
    echo "--- Installing Killing Floor 2 dedicated server (App ${KF2_APP_ID}) ---"
    mkdir -p "${KF2_DIR}"
    cleanup_incomplete_install
    prepare_steam_install_dir

    local status=0
    steamcmd_install_linux_app "${KF2_DIR}" "${KF2_APP_ID}" \
        +app_update "${KF2_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "Killing Floor 2 server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${KF2_APP_ID}" "Killing Floor 2"
        exit 1
    fi

    relocate_install_if_needed
    setup_steam_runtime_libs

    if ! server_present; then
        echo "KF2 server install failed: ${SERVER_BIN} not found." >&2
        ls -la "${KF2_DIR}" >&2 || true
        exit 1
    fi

    chmod +x "${SERVER_BIN}"
}

if ! server_present || [ "${KF2_FORCE_UPDATE}" = "true" ]; then
    install_server
else
    setup_steam_runtime_libs
fi

printf '%s\n' "232090" > "${KF2_DIR}/steam_appid.txt"

cd "${KF2_DIR}"

export LD_LIBRARY_PATH="${KF2_DIR}/linux64:${KF2_DIR}/Binaries/Linux:${LD_LIBRARY_PATH:-}"

args=(
    "${KF2_STARTMAP}"
    "Port=${KF2_PORT}"
    "QueryPort=${KF2_QUERY_PORT}"
)

# shellcheck disable=SC2206
if [ -n "${KF2_EXTRA_ARGS}" ]; then
    extra=( ${KF2_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting Killing Floor 2 dedicated server on port ${KF2_PORT} ---"
exec "${SERVER_BIN}" "${args[@]}"
