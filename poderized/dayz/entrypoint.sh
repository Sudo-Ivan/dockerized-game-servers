#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
DAYZ_APP_ID="${DAYZ_APP_ID:-223350}"
DAYZ_FORCE_UPDATE="${DAYZ_FORCE_UPDATE:-false}"
STEAMCMD_WINDOWS_WORKAROUND="${STEAMCMD_WINDOWS_WORKAROUND:-off}"

DAYZ_PORT="${DAYZ_PORT:-2302}"
DAYZ_HOSTNAME="${DAYZ_HOSTNAME:-DayZ Server}"
DAYZ_MAX_PLAYERS="${DAYZ_MAX_PLAYERS:-60}"
DAYZ_EXTRA_ARGS="${DAYZ_EXTRA_ARGS:-}"

CONFIG_FILE="${DAYZ_DIR}/serverDZ.cfg"
PROFILE_DIR="${DAYZ_DIR}/profiles"
SERVER_BIN=""

resolve_server_bin() {
    if [ -x "${DAYZ_DIR}/DayZServer" ]; then
        SERVER_BIN="${DAYZ_DIR}/DayZServer"
        return 0
    fi
    if [ -x "${DAYZ_DIR}/DayZServer_x64" ]; then
        SERVER_BIN="${DAYZ_DIR}/DayZServer_x64"
        return 0
    fi
    return 1
}

server_present() {
    resolve_server_bin
}

relocate_install_if_needed() {
    if server_present; then
        return
    fi
    local alt_dir=""
    while IFS= read -r alt_dir; do
        if [ -f "${alt_dir}/DayZServer" ] || [ -f "${alt_dir}/DayZServer_x64" ]; then
            echo "--- Moving DayZ server files from ${alt_dir} to ${DAYZ_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${DAYZ_DIR}/${base}" ]; then
                    mv "${item}" "${DAYZ_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/dayz/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

install_server() {
    if [ -z "${STEAM_USERNAME}" ] || [ -z "${STEAM_PASSWORD}" ]; then
        echo "DayZ server install requires STEAM_USERNAME and STEAM_PASSWORD for an account that owns DayZ." >&2
        exit 1
    fi

    echo "--- Installing DayZ dedicated server (App ${DAYZ_APP_ID}) ---"
    mkdir -p "${DAYZ_DIR}"
    local marker="${DAYZ_DIR}/DayZServer"
    if [ ! -f "${marker}" ]; then
        marker="${DAYZ_DIR}/DayZServer_x64"
    fi
    steam_cleanup_incomplete_install "${DAYZ_DIR}" "${DAYZ_APP_ID}" "${marker}"
    steam_prepare_install_dir "${DAYZ_DIR}"

    local status=0
    steamcmd_install_linux_app "${DAYZ_DIR}" "${DAYZ_APP_ID}" \
        +app_update "${DAYZ_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "DayZ server install failed with exit code ${status}" >&2
        echo "SteamCMD needs an account that owns DayZ (client App 221100)." >&2
        exit 1
    fi

    relocate_install_if_needed

    if ! server_present; then
        echo "DayZ server install failed: DayZServer binary not found." >&2
        exit 1
    fi

    chmod +x "${SERVER_BIN}"
}

write_default_config() {
    mkdir -p "${PROFILE_DIR}"
    if [ -f "${CONFIG_FILE}" ]; then
        return
    fi
    cat >"${CONFIG_FILE}" <<EOF
hostname = "${DAYZ_HOSTNAME}";
password = "";
passwordAdmin = "changeme";
maxPlayers = ${DAYZ_MAX_PLAYERS};
verifySignatures = 2;
forceSameBuild = 1;
disableVoN = 0;
vonCodecQuality = 7;
disable3rdPerson = 0;
disableCrosshair = 0;
lightingConfig = 0;
serverTime = "SystemTime";
serverTimeAcceleration = 1;
serverNightTimeAcceleration = 1;
serverTimePersistent = 0;
guaranteedUpdates = 1;
loginQueueConcurrentPlayers = 5;
loginQueueMaxPlayers = 500;
instanceId = 1;
storageAutoFix = 1;

class Missions {
    class DayZ {
        template="dayzOffline.chernarusplus";
    };
};
EOF
}

if ! server_present || [ "${DAYZ_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

write_default_config

cd "${DAYZ_DIR}"
chmod +x "${SERVER_BIN}"

args=(
    -config="${CONFIG_FILE}"
    -port="${DAYZ_PORT}"
    -BEpath=battleye
    -profiles="${PROFILE_DIR}"
    -dologs
    -adminlog
    -netlog
    -freezecheck
)

# shellcheck disable=SC2206
if [ -n "${DAYZ_EXTRA_ARGS}" ]; then
    extra=( ${DAYZ_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting DayZ dedicated server on UDP ${DAYZ_PORT} ---"
exec "${SERVER_BIN}" "${args[@]}"
