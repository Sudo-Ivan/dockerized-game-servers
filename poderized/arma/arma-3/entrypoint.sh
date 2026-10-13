#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

ARMA_CONFIG_DIR="${ARMA_CONFIG_DIR:-/home/arma3/configs}"
ARMA_PROFILES_DIR="${ARMA_PROFILES_DIR:-/home/arma3/profiles}"
ARMA_SERVER_CFG="${ARMA_SERVER_CFG:-${ARMA_CONFIG_DIR}/server.cfg}"
ARMA_PORT="${ARMA_PORT:-2302}"
ARMA_WORLD="${ARMA_WORLD:-empty}"
MODLIST_FILE="${MODLIST_FILE:-/home/arma3/server/modlist.html}"
CDLC="${CDLC:-}"
EXTRA_MODS="${EXTRA_MODS:-}"

mkdir -p "${ARMA_DIR}/keys" "${ARMA_DIR}/mpmissions"

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
ARMA_APP_ID="${ARMA_APP_ID:-233780}"

if [ -z "${STEAM_USERNAME}" ]; then
    STEAM_USERNAME="anonymous"
fi

if [ ! -f "${ARMA_DIR}/arma3server_x64" ]; then
    echo "--- Installing Arma 3 server (App ${ARMA_APP_ID}) ---"
    STEAM_LOGIN="$(steam_login_args)"
    # shellcheck disable=SC2086
    ${STEAM_DIR}/steamcmd.sh +force_install_dir ${ARMA_DIR} +login ${STEAM_LOGIN} +app_update ${ARMA_APP_ID} validate +quit
fi

if [ ! -f "${ARMA_DIR}/arma3server_x64" ]; then
    echo "Arma 3 server binary not found at ${ARMA_DIR}/arma3server_x64" >&2
    steam_install_anonymous_hint "${ARMA_APP_ID}" "Arma 3 Server" >&2
    exit 1
fi

chmod +x "${ARMA_DIR}/arma3server_x64"

if [ ! -f "${ARMA_SERVER_CFG}" ]; then
    echo "Missing ${ARMA_SERVER_CFG}. Create server.cfg before first start." >&2
    exit 1
fi

build_mod_list() {
    local workshop="$1"
    local mod_list="${workshop}"

    if [ -n "${CDLC}" ]; then
        if [ -z "${mod_list}" ]; then
            mod_list="${CDLC}"
        else
            mod_list="${mod_list};${CDLC}"
        fi
    fi
    if [ -n "${EXTRA_MODS}" ]; then
        if [ -z "${mod_list}" ]; then
            mod_list="${EXTRA_MODS}"
        else
            mod_list="${mod_list};${EXTRA_MODS}"
        fi
    fi
    printf '%s' "${mod_list}"
}

link_workshop_mods() {
    local ids="$1"
    local workshop_list=""
    local id

    for id in ${ids}; do
        local src="${ARMA_DIR}/workshop/${id}"
        local link="${ARMA_DIR}/@${id}"
        if [ ! -d "${src}" ]; then
            continue
        fi
        rm -rf "${link}"
        ln -sfn "${src}" "${link}"
        if [ -z "${workshop_list}" ]; then
            workshop_list="@${id}"
        else
            workshop_list="${workshop_list};@${id}"
        fi
    done
    printf '%s' "${workshop_list}"
}

sync_workshop() {
    if [ ! -f "${MODLIST_FILE}" ]; then
        build_mod_list ""
        return
    fi
    if [ -z "${STEAM_USERNAME}" ] || [ "${STEAM_USERNAME}" = "anonymous" ] || [ -z "${STEAM_PASSWORD}" ]; then
        echo "modlist requires STEAM_USERNAME and STEAM_PASSWORD" >&2
        exit 1
    fi

    local output=""
    if ! output="$(python3 /home/arma3/sync_mods.py "${MODLIST_FILE}")"; then
        echo "${output}" >&2
        exit 1
    fi
    link_workshop_mods "${output}"
}

mod_list="$(sync_workshop)"
mod_list="$(build_mod_list "${mod_list}")"

args=(
    -config="${ARMA_SERVER_CFG}"
    -port="${ARMA_PORT}"
    -name=server
    -profiles="${ARMA_PROFILES_DIR}"
    -world="${ARMA_WORLD}"
    -noSound
    -filePatching
)
if [ -n "${mod_list}" ]; then
    args+=(-mod="${mod_list}")
fi

cd "${ARMA_DIR}"
echo "--- Starting Arma 3 server on UDP ${ARMA_PORT} ---"
exec "${ARMA_DIR}/arma3server_x64" "${args[@]}"
