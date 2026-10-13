#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
CSS_APP_ID="${CSS_APP_ID:-232330}"
CSS_FORCE_UPDATE="${CSS_FORCE_UPDATE:-false}"
STEAMCMD_WINDOWS_WORKAROUND="${STEAMCMD_WINDOWS_WORKAROUND:-full}"

CSS_PORT="${CSS_PORT:-27015}"
CSS_CLIENT_PORT="${CSS_CLIENT_PORT:-27005}"
CSS_MAXPLAYERS="${CSS_MAXPLAYERS:-16}"
CSS_STARTMAP="${CSS_STARTMAP:-de_dust2}"
CSS_TICKRATE="${CSS_TICKRATE:-66}"
CSS_GSLT="${CSS_GSLT:-}"
CSS_EXTRA_ARGS="${CSS_EXTRA_ARGS:-}"

SRCDS_RUN="${CSS_DIR}/srcds_run"

server_present() {
    [ -f "${SRCDS_RUN}" ]
}

prepare_steam_install_dir() {
    steam_prepare_install_dir "${CSS_DIR}"
}

cleanup_incomplete_install() {
    steam_cleanup_incomplete_install "${CSS_DIR}" "${CSS_APP_ID}" "${SRCDS_RUN}"
}

relocate_install_if_needed() {
    if server_present; then
        return
    fi

    local alt_dir=""
    while IFS= read -r alt_dir; do
        if [ -f "${alt_dir}/srcds_run" ]; then
            echo "--- Moving server files from ${alt_dir} to ${CSS_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${CSS_DIR}/${base}" ]; then
                    mv "${item}" "${CSS_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/cssource/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

install_server() {
    echo "--- Installing Counter-Strike: Source dedicated server (App ${CSS_APP_ID}) ---"
    mkdir -p "${CSS_DIR}"
    cleanup_incomplete_install
    prepare_steam_install_dir

    local status=0
    steamcmd_install_linux_app "${CSS_DIR}" "${CSS_APP_ID}" \
        +app_update "${CSS_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "Counter-Strike: Source server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${CSS_APP_ID}" "Counter-Strike: Source"
        exit 1
    fi

    relocate_install_if_needed

    if ! server_present; then
        echo "Counter-Strike: Source server install failed: ${SRCDS_RUN} not found." >&2
        ls -la "${CSS_DIR}" >&2 || true
        exit 1
    fi

    chmod +x "${SRCDS_RUN}"
    sed -i 's/\r$//' "${SRCDS_RUN}"
}

if ! server_present || [ "${CSS_FORCE_UPDATE}" = "true" ]; then
    install_server
elif [ -f "${SRCDS_RUN}" ]; then
    sed -i 's/\r$//' "${SRCDS_RUN}"
fi

printf '%s\n' "240" > "${CSS_DIR}/steam_appid.txt"

cd "${CSS_DIR}"

args=(
    -game cstrike
    -console
    -usercon
    -secure
    +port "${CSS_PORT}"
    +clientport "${CSS_CLIENT_PORT}"
    +maxplayers "${CSS_MAXPLAYERS}"
    +map "${CSS_STARTMAP}"
    +hostport "${CSS_PORT}"
    -tickrate "${CSS_TICKRATE}"
    -strictportbind
)

if [ -n "${CSS_GSLT}" ]; then
    args+=("+sv_setsteamaccount" "${CSS_GSLT}")
fi

# shellcheck disable=SC2206
if [ -n "${CSS_EXTRA_ARGS}" ]; then
    extra=( ${CSS_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting Counter-Strike: Source dedicated server on port ${CSS_PORT} ---"
export LD_LIBRARY_PATH="${CSS_DIR}/bin:${CSS_DIR}:/usr/lib32:/usr/lib"
exec "${SRCDS_RUN}" "${args[@]}"
