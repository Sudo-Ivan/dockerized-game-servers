#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
STARBOUND_APP_ID="${STARBOUND_APP_ID:-211820}"
STARBOUND_FORCE_UPDATE="${STARBOUND_FORCE_UPDATE:-false}"

STARBOUND_PORT="${STARBOUND_PORT:-21025}"
STARBOUND_BIND="${STARBOUND_BIND:-0.0.0.0}"
STARBOUND_EXTRA_ARGS="${STARBOUND_EXTRA_ARGS:-}"

SERVER_BINARY="${STARBOUND_DIR}/linux/starbound_server"
CONFIG_FILE="${STARBOUND_DIR}/starbound_server.config"

server_binary_present() {
    [ -f "${SERVER_BINARY}" ]
}

prepare_steam_install_dir() {
    steam_prepare_install_dir "${STARBOUND_DIR}"
}

cleanup_incomplete_install() {
    steam_cleanup_incomplete_install "${STARBOUND_DIR}" "${STARBOUND_APP_ID}" "${SERVER_BINARY}"
}

relocate_install_if_needed() {
    if server_binary_present; then
        return
    fi

    local alt_dir=""
    while IFS= read -r alt_dir; do
        if [ -f "${alt_dir}/linux/starbound_server" ]; then
            echo "--- Moving server files from ${alt_dir} to ${STARBOUND_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${STARBOUND_DIR}/${base}" ]; then
                    mv "${item}" "${STARBOUND_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/starbound/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

install_server() {
    echo "--- Installing Starbound dedicated server (App ${STARBOUND_APP_ID}) ---"
    mkdir -p "${STARBOUND_DIR}"
    cleanup_incomplete_install
    prepare_steam_install_dir

    local status=0
    steamcmd_install_linux_app "${STARBOUND_DIR}" "${STARBOUND_APP_ID}" \
        +app_update "${STARBOUND_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "Starbound server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${STARBOUND_APP_ID}" "Starbound"
        exit 1
    fi

    relocate_install_if_needed

    if ! server_binary_present; then
        echo "Starbound server install failed: ${SERVER_BINARY} not found." >&2
        find "${STARBOUND_DIR}" -maxdepth 3 -type f 2>/dev/null | head -40 >&2 || true
        exit 1
    fi

    chmod +x "${SERVER_BINARY}"
}

write_server_config() {
    if [ -f "${CONFIG_FILE}" ]; then
        return
    fi
    echo "--- Writing default starbound_server.config ---"
    cat > "${CONFIG_FILE}" <<EOF
{
  "gameServerPort" : ${STARBOUND_PORT},
  "gameServerBindAddress" : "${STARBOUND_BIND}",
  "gameServerPassword" : "",
  "maxPlayers" : 8,
  "steamPort" : ${STARBOUND_PORT},
  "steamBindAddress" : "${STARBOUND_BIND}",
  "rconPort" : 21026,
  "rconBindAddress" : "127.0.0.1",
  "rconPassword" : "",
  "allowAdminCommands" : false,
  "allowAnonymousConnections" : true,
  "allowCoordinateConversion" : true,
  "serverName" : "Starbound Server",
  "serverDescription" : "Starbound dedicated server"
}
EOF
}

if ! server_binary_present || [ "${STARBOUND_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

write_server_config

cd "${STARBOUND_DIR}"

echo "--- Starting Starbound server on TCP ${STARBOUND_PORT} ---"
# shellcheck disable=SC2086
exec "${SERVER_BINARY}" -configfile "${CONFIG_FILE}" ${STARBOUND_EXTRA_ARGS}
