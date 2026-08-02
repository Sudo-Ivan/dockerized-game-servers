#!/bin/bash
set -eu

# shellcheck source=/usr/local/bin/linuxgsm-tar-install.sh
. /usr/local/bin/linuxgsm-tar-install.sh

COD2_IP="${COD2_IP:-0.0.0.0}"
COD2_PORT="${COD2_PORT:-28960}"
COD2_MAXPLAYERS="${COD2_MAXPLAYERS:-20}"
COD2_STARTMAP="${COD2_STARTMAP:-mp_leningrad}"
COD2_HOSTNAME="${COD2_HOSTNAME:-Call of Duty 2 Server}"
COD2_EXTRA_ARGS="${COD2_EXTRA_ARGS:-}"

lgsm_volume_seed "${COD2_DIR}" "${COD2_SEED_DIR}" "cod2_lnxded"

cfg="${COD2_DIR}/server.cfg"
if [ ! -f "${cfg}" ]; then
    cat >"${cfg}" <<EOF
set sv_hostname "${COD2_HOSTNAME}"
set rcon_password "changeme"
set g_allowvote 1
EOF
fi

cd "${COD2_DIR}"
chmod +x ./cod2_lnxded

echo "--- Starting Call of Duty 2 dedicated server on port ${COD2_PORT} ---"
# shellcheck disable=SC2086
exec ./cod2_lnxded \
    +set sv_punkbuster 0 \
    +set fs_basepath "${COD2_DIR}" \
    +set dedicated 2 \
    +set net_ip "${COD2_IP}" \
    +set net_port "${COD2_PORT}" \
    +set sv_maxclients "${COD2_MAXPLAYERS}" \
    +map "${COD2_STARTMAP}" \
    +exec server.cfg \
    ${COD2_EXTRA_ARGS}
