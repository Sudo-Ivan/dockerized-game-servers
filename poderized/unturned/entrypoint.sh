#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
UNTURNED_APP_ID="${UNTURNED_APP_ID:-1110390}"
UNTURNED_FORCE_UPDATE="${UNTURNED_FORCE_UPDATE:-false}"

UNTURNED_SERVER_NAME="${UNTURNED_SERVER_NAME:-UnturnedServer}"
UNTURNED_EXTRA_ARGS="${UNTURNED_EXTRA_ARGS:-}"

SERVER_HELPER="${UNTURNED_DIR}/ServerHelper.sh"

server_present() {
    [ -f "${SERVER_HELPER}" ]
}

install_server() {
    echo "--- Installing Unturned dedicated server (App ${UNTURNED_APP_ID}) ---"
    mkdir -p "${UNTURNED_DIR}"
    steam_cleanup_incomplete_install "${UNTURNED_DIR}" "${UNTURNED_APP_ID}" "${SERVER_HELPER}"
    steam_prepare_install_dir "${UNTURNED_DIR}"

    local status=0
    steamcmd_install_linux_app "${UNTURNED_DIR}" "${UNTURNED_APP_ID}" \
        +app_update "${UNTURNED_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "Unturned server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${UNTURNED_APP_ID}" "Unturned"
        exit 1
    fi

    if ! server_present; then
        local alt_dir=""
        while IFS= read -r alt_dir; do
            if [ -f "${alt_dir}/ServerHelper.sh" ]; then
                echo "--- Moving server files from ${alt_dir} to ${UNTURNED_DIR} ---"
                shopt -s dotglob nullglob
                local item base
                for item in "${alt_dir}"/*; do
                    base="$(basename "${item}")"
                    if [ ! -e "${UNTURNED_DIR}/${base}" ]; then
                        mv "${item}" "${UNTURNED_DIR}/"
                    fi
                done
                shopt -u dotglob nullglob
                break
            fi
        done < <(find /home/unturned/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
    fi

    if ! server_present; then
        echo "Unturned server install failed: ${SERVER_HELPER} not found." >&2
        exit 1
    fi

    chmod +x "${SERVER_HELPER}"
}

if ! server_present || [ "${UNTURNED_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

cd "${UNTURNED_DIR}"

args=(
    "+InternetServer/${UNTURNED_SERVER_NAME}"
)

# shellcheck disable=SC2206
if [ -n "${UNTURNED_EXTRA_ARGS}" ]; then
    extra=( ${UNTURNED_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting Unturned dedicated server (${UNTURNED_SERVER_NAME}) ---"
exec bash "${SERVER_HELPER}" "${args[@]}"
