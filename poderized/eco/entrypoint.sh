#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
ECO_APP_ID="${ECO_APP_ID:-739590}"
ECO_FORCE_UPDATE="${ECO_FORCE_UPDATE:-false}"
STEAMCMD_WINDOWS_WORKAROUND="${STEAMCMD_WINDOWS_WORKAROUND:-prime}"

ECO_USER_TOKEN="${ECO_USER_TOKEN:-}"
ECO_OFFLINE="${ECO_OFFLINE:-false}"
ECO_EXTRA_ARGS="${ECO_EXTRA_ARGS:-}"

SERVER_BIN="${ECO_DIR}/EcoServer"

server_present() {
    [ -f "${SERVER_BIN}" ]
}

relocate_install_if_needed() {
    if server_present; then
        return
    fi
    local alt_dir=""
    while IFS= read -r alt_dir; do
        if [ -f "${alt_dir}/EcoServer" ]; then
            echo "--- Moving Eco server files from ${alt_dir} to ${ECO_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${ECO_DIR}/${base}" ]; then
                    mv "${item}" "${ECO_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/eco/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

ensure_steamcmd_runtime() {
    if [ -f "${STEAM_DIR}/linux64/steamclient.so" ]; then
        return 0
    fi
    echo "--- SteamCMD: ensuring steamclient.so is present ---"
    export LD_LIBRARY_PATH="${STEAM_DIR}/linux32:${LD_LIBRARY_PATH:-}"
    local steamcmd_bin
    steamcmd_bin="$(steamcmd_resolve_bin)"
    "${steamcmd_bin}" +quit || true
}

setup_steam_runtime_libs() {
    ensure_steamcmd_runtime
    mkdir -p /home/eco/.steam/sdk32 /home/eco/.steam/sdk64
    mkdir -p "${ECO_DIR}/.steam/sdk32" "${ECO_DIR}/.steam/sdk64"
    if [ -f "${STEAM_DIR}/linux32/steamclient.so" ]; then
        cp -f "${STEAM_DIR}/linux32/steamclient.so" /home/eco/.steam/sdk32/
        cp -f "${STEAM_DIR}/linux32/steamclient.so" "${ECO_DIR}/.steam/sdk32/"
    fi
    if [ -f "${STEAM_DIR}/linux64/steamclient.so" ]; then
        cp -f "${STEAM_DIR}/linux64/steamclient.so" /home/eco/.steam/sdk64/
        cp -f "${STEAM_DIR}/linux64/steamclient.so" "${ECO_DIR}/.steam/sdk64/"
    fi
    if [ ! -f /home/eco/.steam/sdk64/steamclient.so ]; then
        echo "steamclient.so not found under ${STEAM_DIR} after SteamCMD setup." >&2
        exit 1
    fi
}

install_server() {
    echo "--- Installing Eco dedicated server (App ${ECO_APP_ID}) ---"
    mkdir -p "${ECO_DIR}"
    steam_cleanup_incomplete_install "${ECO_DIR}" "${ECO_APP_ID}" "${SERVER_BIN}"
    steam_prepare_install_dir "${ECO_DIR}"

    local status=0
    steamcmd_install_linux_app "${ECO_DIR}" "${ECO_APP_ID}" \
        +app_update "${ECO_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "Eco server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${ECO_APP_ID}" "Eco"
        exit 1
    fi

    relocate_install_if_needed
    setup_steam_runtime_libs

    if ! server_present; then
        echo "Eco server install failed: ${SERVER_BIN} not found." >&2
        exit 1
    fi

    chmod +x "${SERVER_BIN}"
}

if ! server_present || [ "${ECO_FORCE_UPDATE}" = "true" ]; then
    install_server
else
    setup_steam_runtime_libs
fi

cd "${ECO_DIR}"
echo "--- Starting Eco dedicated server ---"
# shellcheck disable=SC2206
args=( -nogui )
if [ "${ECO_OFFLINE}" = "true" ]; then
    args+=( -offline )
elif [ -n "${ECO_USER_TOKEN}" ]; then
    args+=( "-userToken=${ECO_USER_TOKEN}" )
else
    echo "Eco v11+ requires Strange Loop Games authentication." >&2
    echo "Set ECO_USER_TOKEN (from https://play.eco/account) or ECO_OFFLINE=true for offline mode." >&2
    exit 1
fi
if [ -n "${ECO_EXTRA_ARGS}" ]; then
    # shellcheck disable=SC2206
    extra=( ${ECO_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi
export LD_LIBRARY_PATH="${STEAM_DIR}/linux64:${ECO_DIR}/.steam/sdk64:/home/eco/.steam/sdk64:${LD_LIBRARY_PATH:-}"
exec "${SERVER_BIN}" "${args[@]}"
