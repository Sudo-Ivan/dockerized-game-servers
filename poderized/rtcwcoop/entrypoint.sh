#!/bin/bash
set -eu

RTCWCOOP_DIR="${RTCWCOOP_DIR:-/opt/rtcwcoop}"
RTCWCOOP_SEED_DIR="${RTCWCOOP_SEED_DIR:-/usr/share/rtcwcoop-seed}"
RTCWCOOP_IP="${RTCWCOOP_IP:-0.0.0.0}"
RTCWCOOP_PORT="${RTCWCOOP_PORT:-27960}"
RTCWCOOP_MAXPLAYERS="${RTCWCOOP_MAXPLAYERS:-8}"
RTCWCOOP_STARTMAP="${RTCWCOOP_STARTMAP:-escape1}"
RTCWCOOP_HOSTNAME="${RTCWCOOP_HOSTNAME:-RTCWCoop Campaign Server}"
RTCWCOOP_EXTRA_ARGS="${RTCWCOOP_EXTRA_ARGS:-}"

# Copy the baked seed into the data volume without touching files the user
# dropped in first (main/sp_pak1.pk3 is owned retail data).
if [ ! -f "${RTCWCOOP_DIR}/.rtcwcoop-seed-complete" ]; then
    echo "--- Seeding server files into ${RTCWCOOP_DIR} ---"
    mkdir -p "${RTCWCOOP_DIR}"
    cp -rn "${RTCWCOOP_SEED_DIR}/." "${RTCWCOOP_DIR}/"
    touch "${RTCWCOOP_DIR}/.rtcwcoop-seed-complete"
fi

if [ ! -f "${RTCWCOOP_DIR}/main/sp_pak1.pk3" ]; then
    cat >&2 <<EOF
RTCWCoop needs your owned Return to Castle Wolfenstein data.

Copy main/sp_pak1.pk3 from your RTCW install (the Main folder of a Steam or
CD install) into:

  ${RTCWCOOP_DIR}/main/

With the default compose volume that is poderized/rtcwcoop/data/main/sp_pak1.pk3
EOF
    exit 1
fi

cfg="${RTCWCOOP_DIR}/coopmain/server.cfg"
if [ ! -f "${cfg}" ]; then
    mkdir -p "${RTCWCOOP_DIR}/coopmain"
    cat >"${cfg}" <<EOF
set sv_hostname "${RTCWCOOP_HOSTNAME}"
set rcon_password "changeme"
set g_allowvote 1
set sv_maxclients ${RTCWCOOP_MAXPLAYERS}
EOF
fi

cd "${RTCWCOOP_DIR}"
chmod +x ./rtcwcoopded.x86_64

echo "--- Starting RTCWCoop on port ${RTCWCOOP_PORT} ---"
# shellcheck disable=SC2086
exec ./rtcwcoopded.x86_64 \
    +set sv_punkbuster 0 \
    +set fs_basepath "${RTCWCOOP_DIR}" \
    +set fs_game coopmain \
    +set dedicated 1 \
    +set sv_pure 0 \
    +set net_ip "${RTCWCOOP_IP}" \
    +set net_port "${RTCWCOOP_PORT}" \
    +exec server.cfg \
    +map "${RTCWCOOP_STARTMAP}" \
    ${RTCWCOOP_EXTRA_ARGS}
