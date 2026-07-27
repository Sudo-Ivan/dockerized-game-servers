#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
SEVENDTD_APP_ID="${SEVENDTD_APP_ID:-294420}"
SEVENDTD_FORCE_UPDATE="${SEVENDTD_FORCE_UPDATE:-false}"

CONFIG_FILE="${CONFIG_FILE:-serverconfig.xml}"
SEVENDTD_EXTRA_ARGS="${SEVENDTD_EXTRA_ARGS:-}"

SERVER_BINARY="${SEVENDTD_DIR}/7DaysToDieServer.x86_64"
START_SCRIPT="${SEVENDTD_DIR}/startserver.sh"

server_binary_present() {
    [ -f "${SERVER_BINARY}" ]
}

prepare_steam_install_dir() {
    steam_prepare_install_dir "${SEVENDTD_DIR}"
}

cleanup_incomplete_install() {
    steam_cleanup_incomplete_install "${SEVENDTD_DIR}" "${SEVENDTD_APP_ID}" "${SERVER_BINARY}"
}

relocate_install_if_needed() {
    if server_binary_present; then
        return
    fi

    local alt_dir=""
    while IFS= read -r alt_dir; do
        if [ -f "${alt_dir}/7DaysToDieServer.x86_64" ]; then
            echo "--- Moving server files from ${alt_dir} to ${SEVENDTD_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${SEVENDTD_DIR}/${base}" ]; then
                    mv "${item}" "${SEVENDTD_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/sevendtd/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

install_server() {
    echo "--- Installing 7 Days to Die dedicated server (App ${SEVENDTD_APP_ID}) ---"
    mkdir -p "${SEVENDTD_DIR}"
    cleanup_incomplete_install
    prepare_steam_install_dir

    local status=0
    steamcmd_install_linux_app "${SEVENDTD_DIR}" "${SEVENDTD_APP_ID}" \
        +app_update "${SEVENDTD_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "7 Days to Die server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${SEVENDTD_APP_ID}" "7 Days to Die"
        exit 1
    fi

    relocate_install_if_needed

    if ! server_binary_present; then
        echo "7 Days to Die server install failed: ${SERVER_BINARY} not found after Steam reported success." >&2
        ls -la "${SEVENDTD_DIR}" >&2 || true
        exit 1
    fi

    if [ -f "${SERVER_BINARY}" ] && [ ! -x "${SERVER_BINARY}" ]; then
        chmod +x "${SERVER_BINARY}"
    fi
    if [ -f "${START_SCRIPT}" ] && [ ! -x "${START_SCRIPT}" ]; then
        chmod +x "${START_SCRIPT}"
    fi
}

if ! server_binary_present || [ "${SEVENDTD_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

printf '%s\n' "251570" > "${SEVENDTD_DIR}/steam_appid.txt"

cd "${SEVENDTD_DIR}"

config_path="${CONFIG_FILE}"
if [ "${config_path#/}" = "${config_path}" ]; then
    config_path="${SEVENDTD_DIR}/${config_path}"
fi

if [ ! -f "${config_path}" ]; then
    echo "--- Writing default $(basename "${config_path}") (edit under your data volume) ---"
    cat > "${config_path}" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<ServerSettings>
	<property name="ServerName" value="7 Days to Die Server"/>
	<property name="ServerPort" value="26900"/>
	<property name="ServerVisibility" value="2"/>
	<property name="ServerPassword" value=""/>
	<property name="ServerMaxPlayerCount" value="8"/>
	<property name="GameWorld" value="Navezgane"/>
	<property name="GameName" value="Dedicated"/>
	<property name="GameDifficulty" value="2"/>
	<property name="ServerDisabledNetworkProtocols" value="SteamNetworking"/>
</ServerSettings>
EOF
fi

echo "--- Starting 7 Days to Die dedicated server ---"
config_arg="${config_path}"
prefix="${SEVENDTD_DIR}/"
if [ "${config_path#"${prefix}"}" != "${config_path}" ]; then
    config_arg="${config_path#"${prefix}"}"
fi

if [ -x "${START_SCRIPT}" ]; then
    # shellcheck disable=SC2086
    exec "${START_SCRIPT}" -configfile="${config_arg}" ${SEVENDTD_EXTRA_ARGS}
fi

# shellcheck disable=SC2086
exec "${SERVER_BINARY}" \
    -configfile="${config_path}" \
    -dedicated \
    -batchmode \
    -nographics \
    ${SEVENDTD_EXTRA_ARGS}
