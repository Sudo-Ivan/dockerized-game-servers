#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
L4D2_APP_ID="${L4D2_APP_ID:-222860}"
L4D2_FORCE_UPDATE="${L4D2_FORCE_UPDATE:-false}"
STEAMCMD_WINDOWS_WORKAROUND="${STEAMCMD_WINDOWS_WORKAROUND:-full}"

L4D2_PORT="${L4D2_PORT:-27015}"
L4D2_MAXPLAYERS="${L4D2_MAXPLAYERS:-8}"
L4D2_STARTMAP="${L4D2_STARTMAP:-c1m1_hotel}"
L4D2_TICKRATE="${L4D2_TICKRATE:-30}"
L4D2_EXTRA_ARGS="${L4D2_EXTRA_ARGS:-}"

SRCDS_RUN="${L4D2_DIR}/srcds_run"

server_present() {
    [ -f "${SRCDS_RUN}" ]
}

cleanup_incomplete_install() {
    steam_cleanup_incomplete_install "${L4D2_DIR}" "${L4D2_APP_ID}" "${SRCDS_RUN}"
}

relocate_install_if_needed() {
    if server_present; then
        return
    fi

    local alt_dir=""
    while IFS= read -r alt_dir; do
        if [ -f "${alt_dir}/srcds_run" ]; then
            echo "--- Moving server files from ${alt_dir} to ${L4D2_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${L4D2_DIR}/${base}" ]; then
                    mv "${item}" "${L4D2_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/l4d2/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

install_server() {
    echo "--- Installing Left 4 Dead 2 dedicated server (App ${L4D2_APP_ID}) ---"
    mkdir -p "${L4D2_DIR}"
    cleanup_incomplete_install
    steam_prepare_install_dir "${L4D2_DIR}"

    local status=0
    steamcmd_install_linux_app "${L4D2_DIR}" "${L4D2_APP_ID}" \
        +app_update "${L4D2_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "L4D2 server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${L4D2_APP_ID}" "Left 4 Dead 2"
        exit 1
    fi

    relocate_install_if_needed

    if ! server_present; then
        echo "L4D2 server install failed: ${SRCDS_RUN} not found." >&2
        ls -la "${L4D2_DIR}" >&2 || true
        exit 1
    fi

    chmod +x "${SRCDS_RUN}"
}

if ! server_present || [ "${L4D2_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

printf '%s\n' "550" > "${L4D2_DIR}/steam_appid.txt"

cd "${L4D2_DIR}"

args=(
    -game left4dead2
    -console
    -usercon
    +port "${L4D2_PORT}"
    +maxplayers "${L4D2_MAXPLAYERS}"
    +map "${L4D2_STARTMAP}"
    +hostport "${L4D2_PORT}"
    -tickrate "${L4D2_TICKRATE}"
    -strictportbind
)

# shellcheck disable=SC2206
if [ -n "${L4D2_EXTRA_ARGS}" ]; then
    extra=( ${L4D2_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting Left 4 Dead 2 dedicated server on port ${L4D2_PORT} ---"
exec "${SRCDS_RUN}" "${args[@]}"
