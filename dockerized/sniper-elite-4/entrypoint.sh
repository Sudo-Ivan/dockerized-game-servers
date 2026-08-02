#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
SE4_APP_ID="${SE4_APP_ID:-568880}"
SE4_STEAM_APP_ID="${SE4_STEAM_APP_ID:-312660}"
SE4_FORCE_UPDATE="${SE4_FORCE_UPDATE:-false}"

SE4_AUTH_PORT="${SE4_AUTH_PORT:-27000}"
SE4_GAME_PORT="${SE4_GAME_PORT:-27005}"
SE4_LOBBY_PORT="${SE4_LOBBY_PORT:-27010}"
SE4_UPDATE_PORT="${SE4_UPDATE_PORT:-27015}"
SE4_SERVER_NAME="${SE4_SERVER_NAME:-Sniper Elite 4 Server}"
SE4_MAX_PLAYERS="${SE4_MAX_PLAYERS:-12}"
SE4_MAP_ROTATION="${SE4_MAP_ROTATION:-VILLAGE:DM,RIVIERA:DM,COMPOUND:DM,RAILYARD:DM,DOCKYARD:DM}"
SE4_EXTRA_ARGS="${SE4_EXTRA_ARGS:-}"

WINEPREFIX="${WINEPREFIX:-${SE4_DIR}/.wine}"
SE4_CFG="${SE4_DIR}/server.cfg"

server_bin() {
    find "${SE4_DIR}" -maxdepth 2 -name 'SniperElite4_Dedicated.exe' -print -quit 2>/dev/null
}

server_present() {
    [ -n "$(server_bin)" ]
}

prepare_steam_install_dir() {
    steam_prepare_install_dir "${SE4_DIR}"
}

cleanup_incomplete_install() {
    local ready=""
    ready="$(server_bin)"
    steam_cleanup_incomplete_install "${SE4_DIR}" "${SE4_APP_ID}" "${ready}"
}

relocate_install_if_needed() {
    if server_present; then
        return
    fi

    local alt_dir=""
    while IFS= read -r alt_dir; do
        if [ -n "$(find "${alt_dir}" -maxdepth 2 -name 'SniperElite4_Dedicated.exe' -print -quit 2>/dev/null)" ]; then
            echo "--- Moving server files from ${alt_dir} to ${SE4_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${SE4_DIR}/${base}" ]; then
                    mv "${item}" "${SE4_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/se4/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

install_server() {
    echo "--- Installing Sniper Elite 4 dedicated server (App ${SE4_APP_ID}) ---"
    mkdir -p "${SE4_DIR}"
    cleanup_incomplete_install
    prepare_steam_install_dir

    local status=0
    steamcmd_invoke windows "${SE4_DIR}" \
        +@sSteamCmdForcePlatformBitness 64 \
        +app_update "${SE4_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "Sniper Elite 4 server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${SE4_APP_ID}" "Sniper Elite 4"
        exit 1
    fi

    relocate_install_if_needed

    if ! server_present; then
        echo "Sniper Elite 4 server install failed: SniperElite4_Dedicated.exe not found." >&2
        find "${SE4_DIR}" -maxdepth 4 -type f -name '*.exe' 2>/dev/null | head -20 >&2 || true
        exit 1
    fi
}

write_server_cfg() {
    if [ -f "${SE4_CFG}" ]; then
        return
    fi
    echo "--- Writing default server.cfg ---"
    {
        printf 'Server.Name "%s"\n' "${SE4_SERVER_NAME}"
        printf 'Server.AuthPort %s\n' "${SE4_AUTH_PORT}"
        printf 'Server.GamePort %s\n' "${SE4_GAME_PORT}"
        printf 'Server.LobbyPort %s\n' "${SE4_LOBBY_PORT}"
        printf 'Server.UpdatePort %s\n' "${SE4_UPDATE_PORT}"
        printf 'Settings.MaxPlayers %s\n' "${SE4_MAX_PLAYERS}"
        local pair map mode
        IFS=','
        for pair in ${SE4_MAP_ROTATION}; do
            map="${pair%%:*}"
            mode="${pair##*:}"
            [ -n "${map}" ] || continue
            printf 'MapRotation.AddMap %s %s\n' "${map}" "${mode}"
        done
        unset IFS
        printf 'Server.Host\n'
    } > "${SE4_CFG}"
}

init_wine() {
    if [ ! -d "${WINEPREFIX}/drive_c" ]; then
        echo "--- Initializing Wine prefix at ${WINEPREFIX} ---"
        wineboot --init
        wineserver --wait
    fi
}

if ! server_present || [ "${SE4_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

SERVER_BIN="$(server_bin)"
printf '%s\n' "${SE4_STEAM_APP_ID}" > "${SE4_DIR}/steam_appid.txt"

write_server_cfg
init_wine

cd "$(dirname "${SERVER_BIN}")"

args=(
    -authport "${SE4_AUTH_PORT}"
    -updateport "${SE4_UPDATE_PORT}"
    -lobbyport "${SE4_LOBBY_PORT}"
    -gameport "${SE4_GAME_PORT}"
    -exec "${SE4_CFG}"
)

# shellcheck disable=SC2206
if [ -n "${SE4_EXTRA_ARGS}" ]; then
    extra=( ${SE4_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting Sniper Elite 4 dedicated server on UDP ${SE4_GAME_PORT} ---"
exec wine "$(basename "${SERVER_BIN}")" "${args[@]}"
