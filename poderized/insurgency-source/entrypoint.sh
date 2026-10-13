#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
INS_SOURCE_APP_ID="${INS_SOURCE_APP_ID:-237410}"
INS_SOURCE_FORCE_UPDATE="${INS_SOURCE_FORCE_UPDATE:-false}"
STEAMCMD_WINDOWS_WORKAROUND="${STEAMCMD_WINDOWS_WORKAROUND:-full}"

INS_SOURCE_PORT="${INS_SOURCE_PORT:-27015}"
INS_SOURCE_CLIENT_PORT="${INS_SOURCE_CLIENT_PORT:-27016}"
INS_SOURCE_MAXPLAYERS="${INS_SOURCE_MAXPLAYERS:-16}"
INS_SOURCE_STARTMAP="${INS_SOURCE_STARTMAP:-ministry}"
INS_SOURCE_TICKRATE="${INS_SOURCE_TICKRATE:-128}"
INS_SOURCE_EXTRA_ARGS="${INS_SOURCE_EXTRA_ARGS:-}"

SRCDS_RUN="${INS_SOURCE_DIR}/srcds_run"

server_present() {
    [ -f "${SRCDS_RUN}" ]
}

prepare_steam_install_dir() {
    steam_prepare_install_dir "${INS_SOURCE_DIR}"
}

cleanup_incomplete_install() {
    steam_cleanup_incomplete_install "${INS_SOURCE_DIR}" "${INS_SOURCE_APP_ID}" "${SRCDS_RUN}"
}

relocate_install_if_needed() {
    if server_present; then
        return
    fi

    local alt_dir=""
    while IFS= read -r alt_dir; do
        if [ -f "${alt_dir}/srcds_run" ]; then
            echo "--- Moving server files from ${alt_dir} to ${INS_SOURCE_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${INS_SOURCE_DIR}/${base}" ]; then
                    mv "${item}" "${INS_SOURCE_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/inssource/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

install_server() {
    echo "--- Installing Insurgency dedicated server (App ${INS_SOURCE_APP_ID}) ---"
    mkdir -p "${INS_SOURCE_DIR}"
    cleanup_incomplete_install
    prepare_steam_install_dir

    local status=0
    steamcmd_install_linux_app "${INS_SOURCE_DIR}" "${INS_SOURCE_APP_ID}" \
        +app_update "${INS_SOURCE_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "Insurgency server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${INS_SOURCE_APP_ID}" "Insurgency"
        exit 1
    fi

    relocate_install_if_needed

    if ! server_present; then
        echo "Insurgency server install failed: ${SRCDS_RUN} not found." >&2
        ls -la "${INS_SOURCE_DIR}" >&2 || true
        exit 1
    fi

    chmod +x "${SRCDS_RUN}"
    sed -i 's/\r$//' "${SRCDS_RUN}"
}

if ! server_present || [ "${INS_SOURCE_FORCE_UPDATE}" = "true" ]; then
    install_server
elif [ -f "${SRCDS_RUN}" ]; then
    sed -i 's/\r$//' "${SRCDS_RUN}"
fi

printf '%s\n' "222880" > "${INS_SOURCE_DIR}/steam_appid.txt"

cd "${INS_SOURCE_DIR}"

args=(
    -game insurgency
    -console
    -usercon
    +port "${INS_SOURCE_PORT}"
    +clientport "${INS_SOURCE_CLIENT_PORT}"
    +maxplayers "${INS_SOURCE_MAXPLAYERS}"
    +map "${INS_SOURCE_STARTMAP}"
    +hostport "${INS_SOURCE_PORT}"
    -tickrate "${INS_SOURCE_TICKRATE}"
    -strictportbind
)

# shellcheck disable=SC2206
if [ -n "${INS_SOURCE_EXTRA_ARGS}" ]; then
    extra=( ${INS_SOURCE_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting Insurgency dedicated server on port ${INS_SOURCE_PORT} ---"
exec "${SRCDS_RUN}" "${args[@]}"
