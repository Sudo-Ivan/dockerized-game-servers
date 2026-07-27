#!/bin/bash
set -eu

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
SE_APP_ID="${SE_APP_ID:-298740}"
SE_GAME_APP_ID="${SE_GAME_APP_ID:-244850}"
SE_FORCE_UPDATE="${SE_FORCE_UPDATE:-false}"
SE_INSTANCE_NAME="${SE_INSTANCE_NAME:-Default}"
SE_SERVER_NAME="${SE_SERVER_NAME:-Space Engineers}"
SE_WORLD_NAME="${SE_WORLD_NAME:-DedicatedWorld}"
SE_PUBLIC_IP="${SE_PUBLIC_IP:-}"
SE_PORT="${SE_PORT:-27016}"
SE_EXTRA_ARGS="${SE_EXTRA_ARGS:-}"

SERVER_EXE="${SE_DEDICATED_DIR}/DedicatedServer64/SpaceEngineersDedicated.exe"
INSTANCE_DIR="${SE_INSTANCES_DIR}/${SE_INSTANCE_NAME}"
CONFIG_PATH="${INSTANCE_DIR}/SpaceEngineers-Dedicated.cfg"

wine_path() {
    local linux_path="$1"
    local rest="${linux_path#/}"
    rest="${rest//\//\\\\}"
    printf 'Z:\\%s' "${rest}"
}

install_server() {
    echo "--- Installing Space Engineers dedicated server (App ${SE_APP_ID}) ---"
    local steam_login="${STEAM_USERNAME}"
    if [ -n "${STEAM_PASSWORD}" ]; then
        steam_login="${steam_login} ${STEAM_PASSWORD}"
    fi
    export LD_LIBRARY_PATH="${STEAM_DIR}/linux32:${LD_LIBRARY_PATH:-}"
    local status=0
    while true; do
        # shellcheck disable=SC2086
        "${STEAM_DIR}/steamcmd.sh" \
            +@sSteamCmdForcePlatformType windows \
            +@sSteamCmdForcePlatformBitness 64 \
            +force_install_dir "${SE_DEDICATED_DIR}" \
            +login ${steam_login} \
            +app_update "${SE_APP_ID}" validate \
            +quit
        status=$?
        if [ "${status}" -ne 42 ]; then
            break
        fi
    done
    if [ "${status}" -ne 0 ]; then
        echo "Space Engineers server install failed with exit code ${status}" >&2
        exit 1
    fi
    if [ ! -f "${SERVER_EXE}" ]; then
        echo "Space Engineers server install failed: ${SERVER_EXE} not found" >&2
        exit 1
    fi
}

ensure_wine_prefix() {
    if [ ! -f "${WINEPREFIX}/.dgs-dotnet48-ready" ]; then
        echo "--- Preparing Wine prefix (dotnet48, first start may take several minutes) ---"
        WINEPREFIX="${WINEPREFIX}" WINEARCH="${WINEARCH}" WINEDEBUG="${WINEDEBUG}" \
            /home/spaceengineers/wine-setup.sh
    fi
    if [ ! -d "${WINEPREFIX}/drive_c" ]; then
        wineboot --init
        wineserver --wait
    fi
}

write_default_config() {
    mkdir -p "${INSTANCE_DIR}/Saves/${SE_WORLD_NAME}"
    cat > "${CONFIG_PATH}" <<EOF
<?xml version="1.0"?>
<MyObjectBuilder_ConfigDedicated xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <SessionSettings>
    <GameMode>Survival</GameMode>
    <InventorySize>3</InventorySize>
    <BlocksInventorySize>10</BlocksInventorySize>
    <AssemblerSpeedMultiplier>1</AssemblerSpeedMultiplier>
    <AssemblerEfficiencyMultiplier>1</AssemblerEfficiencyMultiplier>
    <MaxFloatingObjects>64</MaxFloatingObjects>
    <TotalPCU>100000</TotalPCU>
    <PiratePCU>50000</PiratePCU>
    <GlobalEncounterPCU>25000</GlobalEncounterPCU>
    <ViewDistance>15000</ViewDistance>
    <EnableSaving>true</EnableSaving>
    <MaxPlayers>4</MaxPlayers>
  </SessionSettings>
  <ServerName>${SE_SERVER_NAME}</ServerName>
  <WorldName>${SE_WORLD_NAME}</WorldName>
  <LoadWorld />
  <IP>0.0.0.0</IP>
  <SteamPort>${SE_PORT}</SteamPort>
  <ServerPort>${SE_PORT}</ServerPort>
  <Plugins />
</MyObjectBuilder_ConfigDedicated>
EOF
}

sync_instance_config() {
    if [ ! -f "${CONFIG_PATH}" ]; then
        write_default_config
    fi

    local instance_ip="${SE_PUBLIC_IP}"
    if [ -z "${instance_ip}" ]; then
        instance_ip="$(hostname -I 2>/dev/null | awk '{print $1}')"
    fi
    if [ -n "${instance_ip}" ]; then
        sed -i -E "s=<IP>.*</IP>=<IP>${instance_ip}</IP>=g" "${CONFIG_PATH}"
    fi

    local save_path
    save_path="$(wine_path "${INSTANCE_DIR}/Saves/${SE_WORLD_NAME}")"
    sed -i -E "s=<LoadWorld />|<LoadWorld>.*</LoadWorld>=<LoadWorld>${save_path}</LoadWorld>=g" "${CONFIG_PATH}"

    if [ -d "${SE_PLUGINS_DIR}" ]; then
        local plugin_count=0
        plugin_count="$(find "${SE_PLUGINS_DIR}" -maxdepth 1 -name '*.dll' 2>/dev/null | wc -l | tr -d ' ')"
        if [ "${plugin_count}" -gt 0 ]; then
            local plugins_xml="<Plugins>"
            local dll
            for dll in "${SE_PLUGINS_DIR}"/*.dll; do
                [ -f "${dll}" ] || continue
                local wine_dll
                wine_dll="$(wine_path "${dll}")"
                plugins_xml="${plugins_xml}<string>${wine_dll}</string>"
            done
            plugins_xml="${plugins_xml}</Plugins>"
            sed -i -E "s=<Plugins />|<Plugins>.*</Plugins>=${plugins_xml}=g" "${CONFIG_PATH}"
        fi
    fi
}

if [ ! -f "${SERVER_EXE}" ] || [ "${SE_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

printf '%s\n' "${SE_GAME_APP_ID}" > "${SE_DEDICATED_DIR}/steam_appid.txt"
mkdir -p "${INSTANCE_DIR}" "${SE_PLUGINS_DIR}"
ensure_wine_prefix
sync_instance_config

instance_wine_path="$(wine_path "${INSTANCE_DIR}")"

cd "${SE_DEDICATED_DIR}/DedicatedServer64"
echo "--- Starting Space Engineers instance ${SE_INSTANCE_NAME} on UDP ${SE_PORT} ---"
# shellcheck disable=SC2086
exec wine "${SERVER_EXE}" \
    -noconsole \
    -ignorelastsession \
    -path "${instance_wine_path}" \
    ${SE_EXTRA_ARGS}
