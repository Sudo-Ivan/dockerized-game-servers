#!/bin/bash
set -eu

JO_DIR="${JO_DIR:-/opt/jointops}"
JO_EXE="${JO_DIR}/jointops.exe"
JO_EXTRA_ARGS="${JO_EXTRA_ARGS:-}"
JO_SERVEONLY="${JO_SERVEONLY:-true}"

require_game_files() {
    if [ ! -f "${JO_EXE}" ]; then
        cat >&2 <<EOF
Joint Operations: Typhoon Rising needs your owned game files.

Copy a Windows install into the data volume so this file exists:
  ${JO_EXE}

There is no headless dedicated server for Joint Operations. The container
runs jointops.exe under Wine and Xvfb with /w /serveonly, the same flags
NovaLogic documented for hosting on a server. You must supply jointops.exe
and the game data from a copy you own (disc install patched to 1.7.5.7 or a
Steam library backup).

Public listing needs a community NovaWorld replacement such as the NovaHQ
service. LAN hosting works without it.
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

cd "${JO_DIR}"
serve_flags=""
if [ "${JO_SERVEONLY}" = "true" ]; then
    serve_flags="/w /serveonly"
fi
echo "--- Starting Joint Operations host ---"
# shellcheck disable=SC2086
exec xvfb-run -a wine "${JO_EXE}" ${serve_flags} ${JO_EXTRA_ARGS}
