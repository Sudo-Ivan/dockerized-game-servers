#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
GMOD_APP_ID="${GMOD_APP_ID:-4020}"
GMOD_FORCE_UPDATE="${GMOD_FORCE_UPDATE:-false}"
STEAMCMD_WINDOWS_WORKAROUND="${STEAMCMD_WINDOWS_WORKAROUND:-full}"

GMOD_PORT="${GMOD_PORT:-27015}"
GMOD_CLIENT_PORT="${GMOD_CLIENT_PORT:-27005}"
GMOD_MAXPLAYERS="${GMOD_MAXPLAYERS:-16}"
GMOD_STARTMAP="${GMOD_STARTMAP:-gm_flatgrass}"
GMOD_TICKRATE="${GMOD_TICKRATE:-66}"
GMOD_GSLT="${GMOD_GSLT:-}"
GMOD_EXTRA_ARGS="${GMOD_EXTRA_ARGS:-}"

SRCDS_RUN="${GMOD_DIR}/srcds_run"

server_present() {
    [ -f "${SRCDS_RUN}" ]
}

install_server() {
    echo "--- Installing Garry's Mod dedicated server (App ${GMOD_APP_ID}) ---"
    mkdir -p "${GMOD_DIR}"
    steam_cleanup_incomplete_install "${GMOD_DIR}" "${GMOD_APP_ID}" "${SRCDS_RUN}"
    steam_prepare_install_dir "${GMOD_DIR}"

    local status=0
    steamcmd_install_linux_app "${GMOD_DIR}" "${GMOD_APP_ID}" \
        +app_update "${GMOD_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "Garry's Mod server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${GMOD_APP_ID}" "Garry's Mod"
        exit 1
    fi

    if ! server_present; then
        local alt_dir=""
        while IFS= read -r alt_dir; do
            if [ -f "${alt_dir}/srcds_run" ]; then
                echo "--- Moving server files from ${alt_dir} to ${GMOD_DIR} ---"
                shopt -s dotglob nullglob
                local item base
                for item in "${alt_dir}"/*; do
                    base="$(basename "${item}")"
                    if [ ! -e "${GMOD_DIR}/${base}" ]; then
                        mv "${item}" "${GMOD_DIR}/"
                    fi
                done
                shopt -u dotglob nullglob
                break
            fi
        done < <(find /home/gmod/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
    fi

    if ! server_present; then
        echo "Garry's Mod server install failed: ${SRCDS_RUN} not found." >&2
        exit 1
    fi

    chmod +x "${SRCDS_RUN}"
    sed -i 's/\r$//' "${SRCDS_RUN}"
}

if ! server_present || [ "${GMOD_FORCE_UPDATE}" = "true" ]; then
    install_server
elif [ -f "${SRCDS_RUN}" ]; then
    sed -i 's/\r$//' "${SRCDS_RUN}"
fi

printf '%s\n' "4000" > "${GMOD_DIR}/steam_appid.txt"

link_steamclient() {
    local sdk_dir="/home/gmod/.steam/sdk32"
    local client_src=""
    if [ -f "${STEAM_DIR}/linux32/steamclient.so" ]; then
        client_src="${STEAM_DIR}/linux32/steamclient.so"
    fi
    if [ -n "${client_src}" ]; then
        mkdir -p "${sdk_dir}"
        ln -sf "${client_src}" "${sdk_dir}/steamclient.so"
    fi
}


link_steamclient

cd "${GMOD_DIR}"

args=(
    -game garrysmod
    -console
    -usercon
    -secure
    +port "${GMOD_PORT}"
    +clientport "${GMOD_CLIENT_PORT}"
    +maxplayers "${GMOD_MAXPLAYERS}"
    +map "${GMOD_STARTMAP}"
    +hostport "${GMOD_PORT}"
    -tickrate "${GMOD_TICKRATE}"
    -strictportbind
)

if [ -n "${GMOD_GSLT}" ]; then
    args+=("+sv_setsteamaccount" "${GMOD_GSLT}")
fi

# shellcheck disable=SC2206
if [ -n "${GMOD_EXTRA_ARGS}" ]; then
    extra=( ${GMOD_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting Garry's Mod dedicated server on port ${GMOD_PORT} ---"
export LD_LIBRARY_PATH="${GMOD_DIR}/bin:${GMOD_DIR}:/usr/lib32:/usr/lib"
exec "${SRCDS_RUN}" "${args[@]}"
