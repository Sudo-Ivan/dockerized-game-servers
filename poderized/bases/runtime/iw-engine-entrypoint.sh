#!/bin/bash
set -eu

iw_server_cfg() {
    local cfg="${1}/server.cfg"
    local hostname="${2:-Dedicated Server}"
    if [ -f "${cfg}" ]; then
        return 0
    fi
    mkdir -p "$(dirname "${cfg}")"
    cat >"${cfg}" <<EOF
set sv_hostname "${hostname}"
set rcon_password "changeme"
set g_allowvote 1
EOF
}

iw_start_cod_like() {
    local dir="${1}"
    local bin="${2}"
    local ip="${3}"
    local port="${4}"
    local maxplayers="${5}"
    local map="${6}"
    local hostname="${7}"
    local extra="${8:-}"

    iw_server_cfg "${dir}" "${hostname}"
    cd "${dir}"
    chmod +x "${bin}"
    # shellcheck disable=SC2086
    exec ./"${bin}" \
        +set sv_punkbuster 0 \
        +set fs_basepath "${dir}" \
        +set dedicated 2 \
        +set net_ip "${ip}" \
        +set net_port "${port}" \
        +set sv_maxclients "${maxplayers}" \
        +map "${map}" \
        +exec server.cfg \
        ${extra}
}
