#!/bin/bash
set -eu

# shellcheck source=/usr/local/bin/linuxgsm-tar-install.sh
. /usr/local/bin/linuxgsm-tar-install.sh

COD_IP="${COD_IP:-0.0.0.0}"
COD_PORT="${COD_PORT:-28960}"
COD_MAXPLAYERS="${COD_MAXPLAYERS:-20}"
COD_STARTMAP="${COD_STARTMAP:-mp_neuville}"
COD_HOSTNAME="${COD_HOSTNAME:-Call of Duty Server}"
COD_EXTRA_ARGS="${COD_EXTRA_ARGS:-}"

lgsm_volume_seed "${COD_DIR}" "${COD_SEED_DIR}" "cod_lnxded"

cfg="${COD_DIR}/server.cfg"
if [ ! -f "${cfg}" ]; then
    cat >"${cfg}" <<EOF
set sv_hostname "${COD_HOSTNAME}"
set rcon_password "changeme"
set g_allowvote 1
EOF
fi

cd "${COD_DIR}"
chmod +x ./cod_lnxded

echo "--- Starting Call of Duty dedicated server on port ${COD_PORT} ---"
# shellcheck disable=SC2086
exec ./cod_lnxded \
    +set sv_punkbuster 0 \
    +set fs_basepath "${COD_DIR}" \
    +set dedicated 2 \
    +set net_ip "${COD_IP}" \
    +set net_port "${COD_PORT}" \
    +set sv_maxclients "${COD_MAXPLAYERS}" \
    +map "${COD_STARTMAP}" \
    +exec server.cfg \
    ${COD_EXTRA_ARGS}
