#!/bin/bash
set -eu

# shellcheck source=/opt/steamcmd/steamcmd-app-update.sh
. /opt/steamcmd/steamcmd-app-update.sh

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
DST_APP_ID="${DST_APP_ID:-343050}"
DST_FORCE_UPDATE="${DST_FORCE_UPDATE:-false}"

DST_CLUSTER="${DST_CLUSTER:-Cluster_1}"
DST_STORAGE_ROOT="${DST_STORAGE_ROOT:-${DST_DIR}/klei}"
DST_CONF_DIR="${DST_CONF_DIR:-DoNotStarveTogether}"
DST_ENABLE_CAVES="${DST_ENABLE_CAVES:-true}"
DST_MAX_PLAYERS="${DST_MAX_PLAYERS:-6}"
DST_GAME_MODE="${DST_GAME_MODE:-survival}"
DST_MASTER_PORT="${DST_MASTER_PORT:-10999}"
DST_CAVES_PORT="${DST_CAVES_PORT:-11000}"
DST_STEAM_MASTER_PORT="${DST_STEAM_MASTER_PORT:-27016}"
DST_CAVES_STEAM_MASTER_PORT="${DST_CAVES_STEAM_MASTER_PORT:-27100}"
DST_MASTER_AUTH_PORT="${DST_MASTER_AUTH_PORT:-8766}"
DST_CAVES_AUTH_PORT="${DST_CAVES_AUTH_PORT:-8767}"
DST_CLUSTER_TOKEN="${DST_CLUSTER_TOKEN:-}"
DST_EXTRA_ARGS="${DST_EXTRA_ARGS:-}"

DST_BIN_DIR="${DST_DIR}/bin64"
DST_BIN="${DST_BIN_DIR}/dontstarve_dedicated_server_nullrenderer_x64"
CLUSTER_DIR="${DST_STORAGE_ROOT}/${DST_CONF_DIR}/${DST_CLUSTER}"
CAVES_PID=""

server_present() {
    [ -f "${DST_BIN}" ]
}

relocate_install_if_needed() {
    if server_present; then
        return
    fi

    local alt_dir=""
    while IFS= read -r alt_dir; do
        if [ -f "${alt_dir}/bin64/dontstarve_dedicated_server_nullrenderer_x64" ]; then
            echo "--- Moving server files from ${alt_dir} to ${DST_DIR} ---"
            shopt -s dotglob nullglob
            local item base
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${DST_DIR}/${base}" ]; then
                    mv "${item}" "${DST_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/dst/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

install_server() {
    echo "--- Installing Don't Starve Together dedicated server (App ${DST_APP_ID}) ---"
    mkdir -p "${DST_DIR}"
    steam_cleanup_incomplete_install "${DST_DIR}" "${DST_APP_ID}" "${DST_BIN}"
    steam_prepare_install_dir "${DST_DIR}"

    local status=0
    steamcmd_install_linux_app "${DST_DIR}" "${DST_APP_ID}" \
        +app_update "${DST_APP_ID}" validate || status=$?
    if [ "${status}" -ne 0 ]; then
        echo "Don't Starve Together server install failed with exit code ${status}" >&2
        steam_install_anonymous_hint "${DST_APP_ID}" "Don't Starve Together"
        exit 1
    fi

    relocate_install_if_needed

    if ! server_present; then
        echo "Don't Starve Together server install failed: ${DST_BIN} not found." >&2
        exit 1
    fi

    chmod +x "${DST_BIN}"
}

ensure_cluster_layout() {
  mkdir -p "${CLUSTER_DIR}/Master" "${CLUSTER_DIR}/Caves"

  if [ ! -f "${CLUSTER_DIR}/cluster.ini" ]; then
    echo "--- Writing default cluster.ini ---"
    cat > "${CLUSTER_DIR}/cluster.ini" <<EOF
[GAMEPLAY]
game_mode = ${DST_GAME_MODE}
max_players = ${DST_MAX_PLAYERS}
pvp = false
pause_when_empty = true
EOF
  fi

  if [ ! -f "${CLUSTER_DIR}/Master/server.ini" ]; then
    cat > "${CLUSTER_DIR}/Master/server.ini" <<EOF
[NETWORK]
server_port = ${DST_MASTER_PORT}

[SHARD]
is_master = true
name = Master
EOF
  fi

  if [ ! -f "${CLUSTER_DIR}/Caves/server.ini" ]; then
    cat > "${CLUSTER_DIR}/Caves/server.ini" <<EOF
[NETWORK]
server_port = ${DST_CAVES_PORT}

[SHARD]
is_master = false
name = Caves
EOF
  fi

  if [ -n "${DST_CLUSTER_TOKEN}" ] && [ ! -f "${CLUSTER_DIR}/cluster_token.txt" ]; then
    echo "--- Writing cluster_token.txt from DST_CLUSTER_TOKEN ---"
    printf '%s\n' "${DST_CLUSTER_TOKEN}" > "${CLUSTER_DIR}/cluster_token.txt"
    chmod 600 "${CLUSTER_DIR}/cluster_token.txt"
  fi

  if [ ! -f "${CLUSTER_DIR}/cluster_token.txt" ]; then
    echo "DST_CLUSTER_TOKEN is not set. The server can run LAN-only until you add cluster_token.txt." >&2
    echo "Create a token at https://accounts.klei.com/ and set DST_CLUSTER_TOKEN or mount cluster_token.txt." >&2
  fi
}

stop_caves() {
    if [ -n "${CAVES_PID}" ] && kill -0 "${CAVES_PID}" 2>/dev/null; then
        kill "${CAVES_PID}" 2>/dev/null || true
        wait "${CAVES_PID}" 2>/dev/null || true
    fi
}

trap stop_caves EXIT INT TERM

if ! server_present || [ "${DST_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

ensure_cluster_layout

export LD_LIBRARY_PATH="${DST_BIN_DIR}:${DST_DIR}/lib64:${LD_LIBRARY_PATH:-}"
cd "${DST_BIN_DIR}"

common_args=(
    -persistent_storage_root "${DST_STORAGE_ROOT}"
    -conf_dir "${DST_CONF_DIR}"
    -cluster "${DST_CLUSTER}"
)

if [ "${DST_ENABLE_CAVES}" = "true" ]; then
    caves_args=(
        "${common_args[@]}"
        -shard Caves
        -bind_ip 127.0.0.1
        -port "${DST_CAVES_PORT}"
        -steam_master_server_port "${DST_CAVES_STEAM_MASTER_PORT}"
        -steam_authentication_port "${DST_CAVES_AUTH_PORT}"
    )
    # shellcheck disable=SC2206
    if [ -n "${DST_EXTRA_ARGS}" ]; then
        extra=( ${DST_EXTRA_ARGS} )
        caves_args+=("${extra[@]}")
    fi
    echo "--- Starting Don't Starve Together Caves shard on UDP ${DST_CAVES_PORT} ---"
    ./dontstarve_dedicated_server_nullrenderer_x64 "${caves_args[@]}" &
    CAVES_PID=$!
    sleep 3
fi

master_args=(
    "${common_args[@]}"
    -shard Master
    -port "${DST_MASTER_PORT}"
    -steam_master_server_port "${DST_STEAM_MASTER_PORT}"
    -steam_authentication_port "${DST_MASTER_AUTH_PORT}"
)

# shellcheck disable=SC2206
if [ -n "${DST_EXTRA_ARGS}" ]; then
    extra=( ${DST_EXTRA_ARGS} )
    master_args+=("${extra[@]}")
fi

echo "--- Starting Don't Starve Together Master shard on UDP ${DST_MASTER_PORT} ---"
exec ./dontstarve_dedicated_server_nullrenderer_x64 "${master_args[@]}"
