#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
DOD_APP_ID="${DOD_APP_ID:-232290}"
DOD_FORCE_UPDATE="${DOD_FORCE_UPDATE:-false}"
STEAMCMD_WINDOWS_WORKAROUND="${STEAMCMD_WINDOWS_WORKAROUND:-full}"

DOD_PORT="${DOD_PORT:-27015}"
DOD_CLIENT_PORT="${DOD_CLIENT_PORT:-27005}"
DOD_MAXPLAYERS="${DOD_MAXPLAYERS:-16}"
DOD_STARTMAP="${DOD_STARTMAP:-dod_anzio}"
DOD_TICKRATE="${DOD_TICKRATE:-66}"
DOD_GSLT="${DOD_GSLT:-}"
DOD_EXTRA_ARGS="${DOD_EXTRA_ARGS:-}"

SRCDS_RUN="${DOD_DIR}/srcds_run"

server_present() {
    [ -f "${SRCDS_RUN}" ]
}

install_server() {
    echo "--- Installing Day of Defeat: Source dedicated server (App ${DOD_APP_ID}) ---"
    mkdir -p "${DOD_DIR}"
    steam_cleanup_incomplete_install "${DOD_DIR}" "${DOD_APP_ID}" "${SRCDS_RUN}"
    steam_prepare_install_dir "${DOD_DIR}"

    local status=0
    steamcmd_install_linux_app "${DOD_DIR}" "${DOD_APP_ID}" \
        +app_update "${DOD_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "Day of Defeat: Source server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${DOD_APP_ID}" "Day of Defeat: Source"
        exit 1
    fi

    if ! server_present; then
        local alt_dir=""
        while IFS= read -r alt_dir; do
            if [ -f "${alt_dir}/srcds_run" ]; then
                echo "--- Moving server files from ${alt_dir} to ${DOD_DIR} ---"
                shopt -s dotglob nullglob
                local item base
                for item in "${alt_dir}"/*; do
                    base="$(basename "${item}")"
                    if [ ! -e "${DOD_DIR}/${base}" ]; then
                        mv "${item}" "${DOD_DIR}/"
                    fi
                done
                shopt -u dotglob nullglob
                break
            fi
        done < <(find /home/dodsource/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
    fi

    if ! server_present; then
        echo "Day of Defeat: Source server install failed: ${SRCDS_RUN} not found." >&2
        exit 1
    fi

    chmod +x "${SRCDS_RUN}"
    sed -i 's/\r$//' "${SRCDS_RUN}"
}

if ! server_present || [ "${DOD_FORCE_UPDATE}" = "true" ]; then
    install_server
elif [ -f "${SRCDS_RUN}" ]; then
    sed -i 's/\r$//' "${SRCDS_RUN}"
fi

printf '%s\n' "300" > "${DOD_DIR}/steam_appid.txt"

link_steamclient() {
    local sdk_dir="/home/dodsource/.steam/sdk32"
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

cd "${DOD_DIR}"

args=(
    -game dod
    -console
    -usercon
    -secure
    +port "${DOD_PORT}"
    +clientport "${DOD_CLIENT_PORT}"
    +maxplayers "${DOD_MAXPLAYERS}"
    +map "${DOD_STARTMAP}"
    +hostport "${DOD_PORT}"
    -tickrate "${DOD_TICKRATE}"
    -strictportbind
)

if [ -n "${DOD_GSLT}" ]; then
    args+=("+sv_setsteamaccount" "${DOD_GSLT}")
fi

# shellcheck disable=SC2206
if [ -n "${DOD_EXTRA_ARGS}" ]; then
    extra=( ${DOD_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting Day of Defeat: Source dedicated server on port ${DOD_PORT} ---"
export LD_LIBRARY_PATH="${DOD_DIR}/bin:${DOD_DIR}:/usr/lib32:/usr/lib"
exec "${SRCDS_RUN}" "${args[@]}"
