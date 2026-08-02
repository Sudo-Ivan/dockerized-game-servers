#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
CS2_APP_ID="${CS2_APP_ID:-730}"
CS2_FORCE_UPDATE="${CS2_FORCE_UPDATE:-false}"

CS2_PORT="${CS2_PORT:-27015}"
CS2_MAXPLAYERS="${CS2_MAXPLAYERS:-10}"
CS2_STARTMAP="${CS2_STARTMAP:-de_dust2}"
CS2_GAME_TYPE="${CS2_GAME_TYPE:-0}"
CS2_GAME_MODE="${CS2_GAME_MODE:-1}"
CS2_GSLT="${CS2_GSLT:-}"
CS2_EXTRA_ARGS="${CS2_EXTRA_ARGS:-}"

CS2_BIN="${CS2_DIR}/game/bin/linuxsteamrt64/cs2"

server_present() {
    [ -x "${CS2_BIN}" ] || [ -f "${CS2_BIN}" ]
}

link_steamclient() {
    local sdk_dir="/home/cs2/.steam/sdk64"
    local client_src=""
    if [ -f "${STEAM_DIR}/linux64/steamclient.so" ]; then
        client_src="${STEAM_DIR}/linux64/steamclient.so"
    elif [ -f "${CS2_DIR}/linuxsteamrt64/libsteamwebrtc.so" ]; then
        return 0
    fi
    if [ -n "${client_src}" ]; then
        mkdir -p "${sdk_dir}"
        ln -sf "${client_src}" "${sdk_dir}/steamclient.so"
    fi
}

install_server() {
    echo "--- Installing Counter-Strike 2 dedicated server (App ${CS2_APP_ID}) ---"
    mkdir -p "${CS2_DIR}"
    steam_cleanup_incomplete_install "${CS2_DIR}" "${CS2_APP_ID}" "${CS2_BIN}"
    steam_prepare_install_dir "${CS2_DIR}"

    local status=0
    steamcmd_install_linux_app "${CS2_DIR}" "${CS2_APP_ID}" \
        +app_update "${CS2_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "Counter-Strike 2 server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${CS2_APP_ID}" "Counter-Strike 2"
        exit 1
    fi

    if ! server_present; then
        local alt_dir=""
        while IFS= read -r alt_dir; do
            if [ -f "${alt_dir}/game/bin/linuxsteamrt64/cs2" ]; then
                echo "--- Moving server files from ${alt_dir} to ${CS2_DIR} ---"
                shopt -s dotglob nullglob
                local item base
                for item in "${alt_dir}"/*; do
                    base="$(basename "${item}")"
                    if [ ! -e "${CS2_DIR}/${base}" ]; then
                        mv "${item}" "${CS2_DIR}/"
                    fi
                done
                shopt -u dotglob nullglob
                break
            fi
        done < <(find /home/cs2/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
    fi

    if ! server_present; then
        echo "Counter-Strike 2 server install failed: ${CS2_BIN} not found." >&2
        exit 1
    fi

    chmod +x "${CS2_BIN}" 2>/dev/null || true
}

if ! server_present || [ "${CS2_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

link_steamclient

cd "${CS2_DIR}/game"

args=(
    -dedicated
    -ip 0.0.0.0
    -port "${CS2_PORT}"
    +hostname "Counter-Strike 2 Server"
    +map "${CS2_STARTMAP}"
    +maxplayers "${CS2_MAXPLAYERS}"
    +game_type "${CS2_GAME_TYPE}"
    +game_mode "${CS2_GAME_MODE}"
    +sv_lan 0
)

if [ -n "${CS2_GSLT}" ]; then
    args+=("+sv_setsteamaccount" "${CS2_GSLT}")
fi

# shellcheck disable=SC2206
if [ -n "${CS2_EXTRA_ARGS}" ]; then
    extra=( ${CS2_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting Counter-Strike 2 dedicated server on port ${CS2_PORT} ---"
exec "${CS2_BIN}" "${args[@]}"
