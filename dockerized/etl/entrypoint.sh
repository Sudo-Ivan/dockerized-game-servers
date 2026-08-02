#!/bin/bash
set -eu

# shellcheck source=/usr/local/bin/linuxgsm-tar-install.sh
. /usr/local/bin/linuxgsm-tar-install.sh

ETL_IP="${ETL_IP:-0.0.0.0}"
ETL_PORT="${ETL_PORT:-27960}"
ETL_MAXPLAYERS="${ETL_MAXPLAYERS:-32}"
ETL_STARTMAP="${ETL_STARTMAP:-oasis}"
ETL_GAMETYPE="${ETL_GAMETYPE:-4}"
ETL_HOSTNAME="${ETL_HOSTNAME:-ET: Legacy Server}"
ETL_EXTRA_ARGS="${ETL_EXTRA_ARGS:-}"
ETL_FORCE_UPDATE="${ETL_FORCE_UPDATE:-false}"

if [ "${ETL_FORCE_UPDATE}" = "true" ]; then
    echo "--- ETL_FORCE_UPDATE: fetching ET: Legacy bundle ---"
    tmp="$(mktemp -d)"
    lgsm_tar_install "${ETL_BUNDLE_URL}" "${ETL_BUNDLE_MD5}" "${tmp}"
    mkdir -p "${ETL_DIR}"
    cp -a "${tmp}/." "${ETL_DIR}/"
    rm -rf "${tmp}"
    touch "${ETL_DIR}/.lgsm-seed-complete"
fi

lgsm_volume_seed "${ETL_DIR}" "${ETL_SEED_DIR}" "etlded"

cfg="${ETL_DIR}/etmain/server.cfg"
if [ ! -f "${cfg}" ]; then
    mkdir -p "${ETL_DIR}/etmain"
    cat >"${cfg}" <<EOF
set com_hunkMegs "56"
set sv_hostname "${ETL_HOSTNAME}"
set g_password ""
set sv_privateclients 0
set g_gametype ${ETL_GAMETYPE}
set g_antilag 1
set sv_maxclients ${ETL_MAXPLAYERS}
set rconpassword "changeme"
set refereePassword "changeme"
set g_allowvote 1
set net_port ${ETL_PORT}
EOF
fi

cd "${ETL_DIR}"
chmod +x ./etlded

echo "--- Starting ET: Legacy on port ${ETL_PORT} ---"
# shellcheck disable=SC2086
exec ./etlded \
    +set net_strict 1 \
    +set fs_homepath "${ETL_DIR}" \
    +set net_ip "${ETL_IP}" \
    +set net_port "${ETL_PORT}" \
    +exec server.cfg \
    +map "${ETL_STARTMAP}" \
    ${ETL_EXTRA_ARGS}
