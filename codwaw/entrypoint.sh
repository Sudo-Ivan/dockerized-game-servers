#!/bin/bash
set -eu

# shellcheck source=/usr/local/bin/linuxgsm-tar-install.sh
. /usr/local/bin/linuxgsm-tar-install.sh

CODWAW_IP="${CODWAW_IP:-0.0.0.0}"
CODWAW_PORT="${CODWAW_PORT:-28960}"
CODWAW_MAXPLAYERS="${CODWAW_MAXPLAYERS:-20}"
CODWAW_STARTMAP="${CODWAW_STARTMAP:-mp_castle}"
CODWAW_HOSTNAME="${CODWAW_HOSTNAME:-Call of Duty: World at War Server}"
CODWAW_EXTRA_ARGS="${CODWAW_EXTRA_ARGS:-}"

lgsm_volume_seed "${CODWAW_DIR}" "${CODWAW_SEED_DIR}" "codwaw_lnxded"

cfg="${CODWAW_DIR}/server.cfg"
if [ ! -f "${cfg}" ]; then
    cat >"${cfg}" <<EOF
set sv_hostname "${CODWAW_HOSTNAME}"
set rcon_password "changeme"
set g_allowvote 1
EOF
fi

cd "${CODWAW_DIR}"
chmod +x ./codwaw_lnxded

echo "--- Starting Call of Duty: World at War dedicated server on port ${CODWAW_PORT} ---"
# shellcheck disable=SC2086
exec ./codwaw_lnxded \
    +set sv_punkbuster 0 \
    +set com_hunkMegs 128 \
    +set fs_basepath "${CODWAW_DIR}" \
    +set dedicated 2 \
    +set net_ip "${CODWAW_IP}" \
    +set net_port "${CODWAW_PORT}" \
    +set sv_maxclients "${CODWAW_MAXPLAYERS}" \
    +map "${CODWAW_STARTMAP}" \
    +exec server.cfg \
    ${CODWAW_EXTRA_ARGS}
