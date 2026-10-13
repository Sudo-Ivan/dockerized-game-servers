#!/bin/bash
set -eu

# shellcheck source=/usr/local/bin/linuxgsm-tar-install.sh
. /usr/local/bin/linuxgsm-tar-install.sh

COD4_IP="${COD4_IP:-0.0.0.0}"
COD4_PORT="${COD4_PORT:-28960}"
COD4_MAXPLAYERS="${COD4_MAXPLAYERS:-32}"
COD4_STARTMAP="${COD4_STARTMAP:-mp_crossfire}"
COD4_HOSTNAME="${COD4_HOSTNAME:-Call of Duty 4 Server}"
COD4_EXTRA_ARGS="${COD4_EXTRA_ARGS:-}"

lgsm_volume_seed "${COD4_DIR}" "${COD4_SEED_DIR}" "cod4x18_dedrun"

cfg="${COD4_DIR}/server.cfg"
if [ ! -f "${cfg}" ]; then
    cat >"${cfg}" <<EOF
set sv_hostname "${COD4_HOSTNAME}"
set rcon_password "changeme"
EOF
fi
cd "${COD4_DIR}"
chmod +x ./cod4x18_dedrun
echo "--- Starting Call of Duty 4 on port ${COD4_PORT} ---"
# shellcheck disable=SC2086
exec ./cod4x18_dedrun \
    +set sv_punkbuster 0 \
    +set fs_basepath "${COD4_DIR}" \
    +set fs_homepath "${COD4_DIR}" \
    +set sv_authorizemode "-1" \
    +set dedicated 2 \
    +set net_ip "${COD4_IP}" \
    +set net_port "${COD4_PORT}" \
    +set sv_maxclients "${COD4_MAXPLAYERS}" \
    +map "${COD4_STARTMAP}" \
    +exec server.cfg \
    ${COD4_EXTRA_ARGS}
