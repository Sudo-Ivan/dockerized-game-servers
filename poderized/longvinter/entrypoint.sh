#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
LONGVINTER_APP_ID="${LONGVINTER_APP_ID:-1639880}"
LONGVINTER_FORCE_UPDATE="${LONGVINTER_FORCE_UPDATE:-false}"

LONGVINTER_PORT="${LONGVINTER_PORT:-7777}"
LONGVINTER_SERVER_NAME="${LONGVINTER_SERVER_NAME:-Longvinter Server}"
LONGVINTER_SERVER_MOTD="${LONGVINTER_SERVER_MOTD:-Welcome to Longvinter!}"
LONGVINTER_MAX_PLAYERS="${LONGVINTER_MAX_PLAYERS:-32}"
LONGVINTER_PASSWORD="${LONGVINTER_PASSWORD:-}"
LONGVINTER_COMMUNITY_WEBSITE="${LONGVINTER_COMMUNITY_WEBSITE:-discord.gg/longvinter}"
LONGVINTER_ADMIN_STEAM_ID="${LONGVINTER_ADMIN_STEAM_ID:-}"
LONGVINTER_PVP="${LONGVINTER_PVP:-true}"
LONGVINTER_TENT_DECAY="${LONGVINTER_TENT_DECAY:-true}"
LONGVINTER_MAX_TENTS="${LONGVINTER_MAX_TENTS:-3}"
LONGVINTER_RESTART_TIME_24H="${LONGVINTER_RESTART_TIME_24H:-6}"
LONGVINTER_SAVE_BACKUPS="${LONGVINTER_SAVE_BACKUPS:-true}"
LONGVINTER_EXTRA_ARGS="${LONGVINTER_EXTRA_ARGS:-}"

SERVER_SCRIPT="${LONGVINTER_DIR}/LongvinterServer.sh"
GAME_INI="${LONGVINTER_DIR}/Longvinter/Saved/Config/LinuxServer/Game.ini"

server_present() {
    [ -f "${SERVER_SCRIPT}" ]
}

prepare_steam_install_dir() {
    steam_prepare_install_dir "${LONGVINTER_DIR}"
}

cleanup_incomplete_install() {
    steam_cleanup_incomplete_install "${LONGVINTER_DIR}" "${LONGVINTER_APP_ID}" "${SERVER_SCRIPT}"
}

relocate_install_if_needed() {
    if server_present; then
        return
    fi

    local alt_dir=""
    while IFS= read -r alt_dir; do
        if [ -f "${alt_dir}/LongvinterServer.sh" ]; then
            echo "--- Moving server files from ${alt_dir} to ${LONGVINTER_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${LONGVINTER_DIR}/${base}" ]; then
                    mv "${item}" "${LONGVINTER_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/longvinter/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

install_server() {
    echo "--- Installing Longvinter dedicated server (App ${LONGVINTER_APP_ID}) ---"
    mkdir -p "${LONGVINTER_DIR}"
    cleanup_incomplete_install
    prepare_steam_install_dir

    local status=0
    steamcmd_install_linux_app "${LONGVINTER_DIR}" "${LONGVINTER_APP_ID}" \
        +app_update "${LONGVINTER_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "Longvinter server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${LONGVINTER_APP_ID}" "Longvinter"
        exit 1
    fi

    relocate_install_if_needed

    if ! server_present; then
        echo "Longvinter server install failed: ${SERVER_SCRIPT} not found." >&2
        ls -la "${LONGVINTER_DIR}" >&2 || true
        exit 1
    fi

    chmod +x "${SERVER_SCRIPT}"
}

write_game_ini() {
    if [ -f "${GAME_INI}" ]; then
        return
    fi

    echo "--- Writing default Game.ini ---"
    mkdir -p "$(dirname "${GAME_INI}")"
    cat > "${GAME_INI}" <<EOF
[/Game/Blueprints/Server/GI_AdvancedSessions.GI_AdvancedSessions_C]
ServerName=${LONGVINTER_SERVER_NAME}
ServerMOTD=${LONGVINTER_SERVER_MOTD}
MaxPlayers=${LONGVINTER_MAX_PLAYERS}
Password=${LONGVINTER_PASSWORD}
CommunityWebsite=${LONGVINTER_COMMUNITY_WEBSITE}
CoopPlay=false
CheckVPN=true
CoopSpawn=0
Tag=none
ChestRespawnTime=900
DisableWanderingTraders=false

[/Game/Blueprints/Server/GM_Longvinter.GM_Longvinter_C]
AdminSteamID=${LONGVINTER_ADMIN_STEAM_ID}
PVP=${LONGVINTER_PVP}
TentDecay=${LONGVINTER_TENT_DECAY}
MaxTents=${LONGVINTER_MAX_TENTS}
RestartTime24h=${LONGVINTER_RESTART_TIME_24H}
SaveBackups=${LONGVINTER_SAVE_BACKUPS}
EOF
}

if ! server_present || [ "${LONGVINTER_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

write_game_ini

cd "${LONGVINTER_DIR}"

lv_args=(
    "-GamePort=${LONGVINTER_PORT}"
)

# shellcheck disable=SC2206
if [ -n "${LONGVINTER_EXTRA_ARGS}" ]; then
    extra=( ${LONGVINTER_EXTRA_ARGS} )
    lv_args+=("${extra[@]}")
fi

echo "--- Starting Longvinter dedicated server on UDP ${LONGVINTER_PORT} ---"
exec bash "${SERVER_SCRIPT}" "${lv_args[@]}"
