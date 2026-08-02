#!/bin/bash
set -eu

# shellcheck source=/usr/local/bin/linuxgsm-tar-install.sh
. /usr/local/bin/linuxgsm-tar-install.sh

RTCW_IP="${RTCW_IP:-0.0.0.0}"
RTCW_PORT="${RTCW_PORT:-27960}"
RTCW_MAXPLAYERS="${RTCW_MAXPLAYERS:-32}"
RTCW_STARTMAP="${RTCW_STARTMAP:-mp_beach}"
RTCW_HOSTNAME="${RTCW_HOSTNAME:-Return to Castle Wolfenstein Server}"
RTCW_EXTRA_ARGS="${RTCW_EXTRA_ARGS:-}"

lgsm_volume_seed "${RTCW_DIR}" "${RTCW_SEED_DIR}" "iowolfded.x86_64"

cfg="${RTCW_DIR}/main/server.cfg"
if [ ! -f "${cfg}" ]; then
    mkdir -p "${RTCW_DIR}/main"
    cat >"${cfg}" <<EOF
set sv_hostname "${RTCW_HOSTNAME}"
set rcon_password "changeme"
set g_allowvote 1
set sv_maxclients ${RTCW_MAXPLAYERS}
EOF
fi

cd "${RTCW_DIR}"
chmod +x ./iowolfded.x86_64

echo "--- Starting Return to Castle Wolfenstein on port ${RTCW_PORT} ---"
# shellcheck disable=SC2086
exec ./iowolfded.x86_64 \
    +set sv_punkbuster 0 \
    +set fs_basepath "${RTCW_DIR}" \
    +set dedicated 1 \
    +set net_ip "${RTCW_IP}" \
    +set net_port "${RTCW_PORT}" \
    +exec server.cfg \
    +map "${RTCW_STARTMAP}" \
    ${RTCW_EXTRA_ARGS}
