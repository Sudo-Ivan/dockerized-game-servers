#!/bin/bash
set -eu

BHD_EXE="${BHD_DIR}/dfbhd.exe"
BHD_EXTRA_ARGS="${BHD_EXTRA_ARGS:-}"

require_game_files() {
    if [ ! -f "${BHD_EXE}" ]; then
        cat >&2 <<EOF
Delta Force: Black Hawk Down needs your owned game files.

Copy a Windows install into the data volume so this file exists:
  ${BHD_EXE}

There is no SteamCMD dedicated server for BHD. You must supply dfbhd.exe and
the game data from a copy you own (disc install or existing Steam library backup).

Community multiplayer often needs NovaHQ heartbeat tools outside this container.
EOF
        exit 1
    fi
}

init_wine() {
    if [ ! -d "${WINEPREFIX}/drive_c" ]; then
        echo "--- Initializing Wine prefix ---"
        wineboot --init
        wineserver --wait
    fi
}

require_game_files
init_wine

cd "${BHD_DIR}"

echo "--- Starting Delta Force: Black Hawk Down (Wine) ---"
echo "--- Use in-game multiplayer hosting or community tools such as HawkSync ---"

# shellcheck disable=SC2086
exec xvfb-run -a wine "${BHD_EXE}" ${BHD_EXTRA_ARGS}
