#!/bin/bash
set -eu

export WINEARCH="${WINEARCH:-win64}"
export WINEDEBUG="${WINEDEBUG:--all}"
export WINEPREFIX="${WINEPREFIX:?WINEPREFIX required}"
export WINEDLLOVERRIDES="${WINEDLLOVERRIDES:-mscoree=d}"

xvfb_pid=""
cleanup() {
    if [ -n "${xvfb_pid}" ] && kill -0 "${xvfb_pid}" 2>/dev/null; then
        kill "${xvfb_pid}" 2>/dev/null || true
        wait "${xvfb_pid}" 2>/dev/null || true
    fi
}
trap cleanup EXIT

Xvfb :99 -screen 0 1024x768x16 -nolisten tcp &
xvfb_pid=$!
export DISPLAY=:99

wineboot --init
wineserver --wait
winetricks -q sound=disabled corefonts
winetricks -q vcrun2019
winetricks -q dotnet48
wineserver --wait

touch "${WINEPREFIX}/.dgs-dotnet48-ready"
