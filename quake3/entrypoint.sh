#!/bin/bash
set -eu

# shellcheck source=/usr/local/bin/linuxgsm-tar-install.sh
. /usr/local/bin/linuxgsm-tar-install.sh

Q3_IP="${Q3_IP:-0.0.0.0}"
Q3_PORT="${Q3_PORT:-27960}"
Q3_STARTMAP="${Q3_STARTMAP:-q3dm17}"
Q3_HOSTNAME="${Q3_HOSTNAME:-Quake 3 Arena Server}"
Q3_EXTRA_ARGS="${Q3_EXTRA_ARGS:-}"
lgsm_volume_seed "${Q3_DIR}" "${Q3_SEED_DIR}" "q3ded"

cfg="${Q3_DIR}/server.cfg"
if [ ! -f "${cfg}" ]; then
    cat >"${cfg}" <<EOF
set sv_hostname "${Q3_HOSTNAME}"
set g_allowvote 1
EOF
fi
cd "${Q3_DIR}"
chmod +x ./q3ded
echo "--- Starting Quake 3 Arena on port ${Q3_PORT} ---"
# shellcheck disable=SC2086
exec ./q3ded \
    +set sv_punkbuster 0 \
    +set fs_basepath "${Q3_DIR}" \
    +set dedicated 2 \
    +set com_hunkMegs 32 \
    +set net_ip "${Q3_IP}" \
    +set net_port "${Q3_PORT}" \
    +map "${Q3_STARTMAP}" \
    +exec server.cfg \
    ${Q3_EXTRA_ARGS}
