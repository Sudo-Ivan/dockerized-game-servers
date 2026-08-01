#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
TF2_APP_ID="${TF2_APP_ID:-232250}"
TF2_FORCE_UPDATE="${TF2_FORCE_UPDATE:-false}"
STEAMCMD_WINDOWS_WORKAROUND="${STEAMCMD_WINDOWS_WORKAROUND:-full}"

TF2_PORT="${TF2_PORT:-27015}"
TF2_CLIENT_PORT="${TF2_CLIENT_PORT:-27005}"
TF2_MAXPLAYERS="${TF2_MAXPLAYERS:-24}"
TF2_STARTMAP="${TF2_STARTMAP:-cp_dustbowl}"
TF2_TICKRATE="${TF2_TICKRATE:-66}"
TF2_GSLT="${TF2_GSLT:-}"
TF2_EXTRA_ARGS="${TF2_EXTRA_ARGS:-}"

SRCDS_RUN="${TF2_DIR}/srcds_run"

server_present() {
    [ -f "${SRCDS_RUN}" ]
}

install_server() {
    echo "--- Installing Team Fortress 2 dedicated server (App ${TF2_APP_ID}) ---"
    mkdir -p "${TF2_DIR}"
    steam_cleanup_incomplete_install "${TF2_DIR}" "${TF2_APP_ID}" "${SRCDS_RUN}"
    steam_prepare_install_dir "${TF2_DIR}"

    local status=0
    steamcmd_install_linux_app "${TF2_DIR}" "${TF2_APP_ID}" \
        +app_update "${TF2_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "Team Fortress 2 server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${TF2_APP_ID}" "Team Fortress 2"
        exit 1
    fi

    if ! server_present; then
        local alt_dir=""
        while IFS= read -r alt_dir; do
            if [ -f "${alt_dir}/srcds_run" ]; then
                echo "--- Moving server files from ${alt_dir} to ${TF2_DIR} ---"
                shopt -s dotglob nullglob
                local item base
                for item in "${alt_dir}"/*; do
                    base="$(basename "${item}")"
                    if [ ! -e "${TF2_DIR}/${base}" ]; then
                        mv "${item}" "${TF2_DIR}/"
                    fi
                done
                shopt -u dotglob nullglob
                break
            fi
        done < <(find /home/tf2/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
    fi

    if ! server_present; then
        echo "Team Fortress 2 server install failed: ${SRCDS_RUN} not found." >&2
        exit 1
    fi

    chmod +x "${SRCDS_RUN}"
    sed -i 's/\r$//' "${SRCDS_RUN}"
}

if ! server_present || [ "${TF2_FORCE_UPDATE}" = "true" ]; then
    install_server
elif [ -f "${SRCDS_RUN}" ]; then
    sed -i 's/\r$//' "${SRCDS_RUN}"
fi

printf '%s\n' "440" > "${TF2_DIR}/steam_appid.txt"

cd "${TF2_DIR}"

args=(
    -game tf
    -console
    -usercon
    -secure
    +port "${TF2_PORT}"
    +clientport "${TF2_CLIENT_PORT}"
    +maxplayers "${TF2_MAXPLAYERS}"
    +map "${TF2_STARTMAP}"
    +hostport "${TF2_PORT}"
    -tickrate "${TF2_TICKRATE}"
    -strictportbind
)

if [ -n "${TF2_GSLT}" ]; then
    args+=("+sv_setsteamaccount" "${TF2_GSLT}")
fi

# shellcheck disable=SC2206
if [ -n "${TF2_EXTRA_ARGS}" ]; then
    extra=( ${TF2_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting Team Fortress 2 dedicated server on port ${TF2_PORT} ---"
export LD_LIBRARY_PATH="${TF2_DIR}/bin:${TF2_DIR}:/usr/lib32:/usr/lib"
exec "${SRCDS_RUN}" "${args[@]}"
