#!/bin/bash
set -eu

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
INS_SANDSTORM_APP_ID="${INS_SANDSTORM_APP_ID:-581330}"
INS_SANDSTORM_FORCE_UPDATE="${INS_SANDSTORM_FORCE_UPDATE:-false}"

INS_SANDSTORM_PORT="${INS_SANDSTORM_PORT:-27102}"
INS_SANDSTORM_QUERY_PORT="${INS_SANDSTORM_QUERY_PORT:-27131}"
INS_SANDSTORM_MAXPLAYERS="${INS_SANDSTORM_MAXPLAYERS:-28}"
INS_SANDSTORM_MAP="${INS_SANDSTORM_MAP:-Oilfield}"
INS_SANDSTORM_SCENARIO="${INS_SANDSTORM_SCENARIO:-Scenario_Refinery_Push_Security}"
INS_SANDSTORM_HOSTNAME="${INS_SANDSTORM_HOSTNAME:-Sandstorm Server}"
INS_SANDSTORM_GSLT="${INS_SANDSTORM_GSLT:-}"
INS_SANDSTORM_GAMESTATS_TOKEN="${INS_SANDSTORM_GAMESTATS_TOKEN:-}"
INS_SANDSTORM_EXTRA_ARGS="${INS_SANDSTORM_EXTRA_ARGS:-}"

SERVER_BIN="${INS_SANDSTORM_DIR}/Insurgency/Binaries/Linux/InsurgencyServer-Linux-Shipping"

server_present() {
    [ -f "${SERVER_BIN}" ]
}

prepare_steam_install_dir() {
    mkdir -p "${INS_SANDSTORM_DIR}/steamapps"
    cat > "${INS_SANDSTORM_DIR}/steamapps/libraryfolders.vdf" <<EOF
"LibraryFolders"
{
    "0" "${INS_SANDSTORM_DIR}"
}
EOF
}

cleanup_incomplete_install() {
    if [ -d "${INS_SANDSTORM_DIR}/steamapps" ] && ! server_present; then
        echo "--- Removing incomplete Steam install state from ${INS_SANDSTORM_DIR} ---"
        rm -rf "${INS_SANDSTORM_DIR}/steamapps" "${INS_SANDSTORM_DIR}/package"
    fi
}

relocate_install_if_needed() {
    if server_present; then
        return
    fi

    local alt_dir=""
    while IFS= read -r alt_dir; do
        if [ -f "${alt_dir}/Insurgency/Binaries/Linux/InsurgencyServer-Linux-Shipping" ]; then
            echo "--- Moving server files from ${alt_dir} to ${INS_SANDSTORM_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${INS_SANDSTORM_DIR}/${base}" ]; then
                    mv "${item}" "${INS_SANDSTORM_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/inssandstorm/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

setup_steam_runtime_libs() {
    mkdir -p "${INS_SANDSTORM_DIR}/.steam/sdk32" "${INS_SANDSTORM_DIR}/.steam/sdk64"
    if [ -f "${STEAM_DIR}/linux32/steamclient.so" ]; then
        cp -f "${STEAM_DIR}/linux32/steamclient.so" "${INS_SANDSTORM_DIR}/.steam/sdk32/"
    fi
    if [ -f "${STEAM_DIR}/linux64/steamclient.so" ]; then
        cp -f "${STEAM_DIR}/linux64/steamclient.so" "${INS_SANDSTORM_DIR}/.steam/sdk64/"
    fi
}

install_server() {
    echo "--- Installing Insurgency: Sandstorm dedicated server (App ${INS_SANDSTORM_APP_ID}) ---"
    mkdir -p "${INS_SANDSTORM_DIR}"
    cleanup_incomplete_install
    prepare_steam_install_dir

    local steam_login="${STEAM_USERNAME}"
    if [ -n "${STEAM_PASSWORD}" ]; then
        steam_login="${steam_login} ${STEAM_PASSWORD}"
    fi
    export LD_LIBRARY_PATH="${STEAM_DIR}/linux32:${LD_LIBRARY_PATH:-}"
    local status=0
    while true; do
        # shellcheck disable=SC2086
        "${STEAM_DIR}/linux32/steamcmd" \
            +@sSteamCmdForcePlatformType linux \
            +force_install_dir "${INS_SANDSTORM_DIR}" \
            +login ${steam_login} \
            +app_update "${INS_SANDSTORM_APP_ID}" validate \
            +quit
        status=$?
        if [ "${status}" -ne 42 ]; then
            break
        fi
    done
    if [ "${status}" -ne 0 ]; then
        echo "Insurgency: Sandstorm server install failed with exit code ${status}" >&2
        exit 1
    fi

    relocate_install_if_needed
    setup_steam_runtime_libs

    if ! server_present; then
        echo "Insurgency: Sandstorm server install failed: ${SERVER_BIN} not found." >&2
        ls -la "${INS_SANDSTORM_DIR}" >&2 || true
        exit 1
    fi

    chmod +x "${SERVER_BIN}"
}

if ! server_present || [ "${INS_SANDSTORM_FORCE_UPDATE}" = "true" ]; then
    install_server
else
    setup_steam_runtime_libs
fi

printf '%s\n' "581320" > "${INS_SANDSTORM_DIR}/steam_appid.txt"

map_arg="${INS_SANDSTORM_MAP}?Scenario=${INS_SANDSTORM_SCENARIO}?MaxPlayers=${INS_SANDSTORM_MAXPLAYERS}"

args=(
    "${map_arg}"
    "-Port=${INS_SANDSTORM_PORT}"
    "-QueryPort=${INS_SANDSTORM_QUERY_PORT}"
    -log
    "-hostname=${INS_SANDSTORM_HOSTNAME}"
)

if [ -n "${INS_SANDSTORM_GSLT}" ]; then
    args+=("-GSLTToken=${INS_SANDSTORM_GSLT}")
fi

if [ -n "${INS_SANDSTORM_GAMESTATS_TOKEN}" ]; then
    args+=(-GameStats "-GameStatsToken=${INS_SANDSTORM_GAMESTATS_TOKEN}")
fi

# shellcheck disable=SC2206
if [ -n "${INS_SANDSTORM_EXTRA_ARGS}" ]; then
    extra=( ${INS_SANDSTORM_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

cd "${INS_SANDSTORM_DIR}"
echo "--- Starting Insurgency: Sandstorm on port ${INS_SANDSTORM_PORT} ---"
exec "${SERVER_BIN}" "${args[@]}"
