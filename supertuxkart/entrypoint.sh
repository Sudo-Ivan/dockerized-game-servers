#!/bin/bash
set -eu

STK_ONLINE_USERNAME="${STK_ONLINE_USERNAME:-}"
STK_ONLINE_PASSWORD="${STK_ONLINE_PASSWORD:-}"
STK_MODE="${STK_MODE:-lan}"
STK_SERVER_NAME="${STK_SERVER_NAME:-SuperTuxKart Server}"
STK_PORT="${STK_PORT:-2759}"
STK_MAX_PLAYERS="${STK_MAX_PLAYERS:-8}"
STK_GAME_MODE="${STK_GAME_MODE:-3}"
STK_DIFFICULTY="${STK_DIFFICULTY:-0}"
STK_PASSWORD="${STK_PASSWORD:-}"
STK_RANKED="${STK_RANKED:-false}"
STK_OWNER_LESS="${STK_OWNER_LESS:-false}"
STK_TRACK_VOTING="${STK_TRACK_VOTING:-true}"
STK_FIREWALLED="${STK_FIREWALLED:-true}"
STK_MIN_START_PLAYERS="${STK_MIN_START_PLAYERS:-2}"
STK_MOTD="${STK_MOTD:-}"
STK_EXTRA_ARGS="${STK_EXTRA_ARGS:-}"

SERVER_BIN="${STK_DIR}/bin/supertuxkart"
SERVER_CFG="${STK_DATA_DIR}/server_config.xml"

export HOME="${STK_DATA_DIR}/home"
mkdir -p "${HOME}"

CONFIG_DIR="${HOME}/.config/supertuxkart/config-0.10"
PLAYERS_XML="${CONFIG_DIR}/players.xml"

link_online_account() {
    if [ -z "${STK_ONLINE_USERNAME}" ] || [ -z "${STK_ONLINE_PASSWORD}" ]; then
        return
    fi
    if [ -f "${PLAYERS_XML}" ]; then
        return
    fi
    echo "--- Registering STK Online session for ${STK_ONLINE_USERNAME} ---"
    "${SERVER_BIN}" --init-user \
        --login="${STK_ONLINE_USERNAME}" \
        --password="${STK_ONLINE_PASSWORD}"
}

write_server_config() {
    if [ -f "${SERVER_CFG}" ]; then
        return
    fi
    echo "--- Writing default server_config.xml ---"
    local wan_value="false"
    if [ "${STK_MODE}" = "wan" ]; then
        wan_value="true"
    fi
    cat > "${SERVER_CFG}" <<EOF
<?xml version="1.0"?>
<server-config version="6" >
    <server-name value="${STK_SERVER_NAME}" />
    <server-port value="${STK_PORT}" />
    <server-mode value="${STK_GAME_MODE}" />
    <server-difficulty value="${STK_DIFFICULTY}" />
    <wan-server value="${wan_value}" />
    <enable-console value="false" />
    <server-max-players value="${STK_MAX_PLAYERS}" />
    <private-server-password value="${STK_PASSWORD}" />
    <motd value="${STK_MOTD}" />
    <track-voting value="${STK_TRACK_VOTING}" />
    <ranked value="${STK_RANKED}" />
    <owner-less value="${STK_OWNER_LESS}" />
    <firewalled-server value="${STK_FIREWALLED}" />
    <min-start-game-players value="${STK_MIN_START_PLAYERS}" />
</server-config>
EOF
}

link_online_account
write_server_config

cd "${STK_DATA_DIR}"

args=(
    --server-config="${SERVER_CFG}"
)

if [ "${STK_MODE}" = "wan" ]; then
    args+=(--wan-server="${STK_SERVER_NAME}")
else
    args+=(--lan-server="${STK_SERVER_NAME}")
fi

# shellcheck disable=SC2206
if [ -n "${STK_EXTRA_ARGS}" ]; then
    extra=( ${STK_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting SuperTuxKart ${STK_MODE} server on UDP ${STK_PORT} ---"
exec "${SERVER_BIN}" "${args[@]}"
