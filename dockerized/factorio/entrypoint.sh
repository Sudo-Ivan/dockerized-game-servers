#!/bin/bash
set -eu

FACTORIO_VERSION="${FACTORIO_VERSION:-stable}"
FACTORIO_FORCE_UPDATE="${FACTORIO_FORCE_UPDATE:-false}"
FACTORIO_DOWNLOAD_URL="${FACTORIO_DOWNLOAD_URL:-https://www.factorio.com/get-download/${FACTORIO_VERSION}/headless/linux64}"

SERVER_NAME="${SERVER_NAME:-Factorio Server}"
SERVER_DESCRIPTION="${SERVER_DESCRIPTION:-Factorio dedicated server}"
SERVER_PASSWORD="${SERVER_PASSWORD:-}"
MAX_PLAYERS="${MAX_PLAYERS:-0}"
SAVE_NAME="${SAVE_NAME:-world}"
LOAD_LATEST="${LOAD_LATEST:-false}"
PORT="${PORT:-34197}"
BIND="${BIND:-0.0.0.0}"
RCON_PORT="${RCON_PORT:-27015}"
RCON_PASSWORD="${RCON_PASSWORD:-}"
PUBLIC_VISIBILITY="${PUBLIC_VISIBILITY:-false}"
LAN_VISIBILITY="${LAN_VISIBILITY:-true}"
AUTOSAVE_INTERVAL="${AUTOSAVE_INTERVAL:-10}"
AUTO_PAUSE="${AUTO_PAUSE:-true}"
FACTORIO_EXTRA_ARGS="${FACTORIO_EXTRA_ARGS:-}"

SERVER_BINARY="${FACTORIO_DIR}/bin/x64/factorio"
CONFIG_DIR="${FACTORIO_DIR}/config"
SAVES_DIR="${FACTORIO_DIR}/saves"
SETTINGS_FILE="${CONFIG_DIR}/server-settings.json"
SAVE_FILE="${SAVES_DIR}/${SAVE_NAME}.zip"
VERSION_FILE="${FACTORIO_DIR}/.installed-version"

server_binary_present() {
    [ -x "${SERVER_BINARY}" ] || [ -f "${SERVER_BINARY}" ]
}

json_escape() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "${s}"
}

install_server() {
    echo "--- Installing Factorio headless (${FACTORIO_VERSION}) ---"
    mkdir -p "${FACTORIO_DIR}"
    local archive="/tmp/factorio-headless.tar.xz"
    local extract_dir="/tmp/factorio-extract"

    rm -rf "${extract_dir}"
    mkdir -p "${extract_dir}"

    # shellcheck source=dockerized/bases/runtime/http-download.sh
    . /usr/local/bin/http-download.sh
    http_download_file "${FACTORIO_DOWNLOAD_URL}" "${archive}"

    tar -xJf "${archive}" -C "${extract_dir}"
    rm -f "${archive}"

    if [ ! -f "${extract_dir}/factorio/bin/x64/factorio" ]; then
        echo "Factorio archive layout unexpected. Contents:" >&2
        find "${extract_dir}" -maxdepth 3 -print >&2 || true
        exit 1
    fi

    # Preserve persistent runtime dirs across updates.
    local preserve=""
    for preserve in saves config mods script-output; do
        if [ -e "${FACTORIO_DIR}/${preserve}" ]; then
            mv "${FACTORIO_DIR}/${preserve}" "/tmp/factorio-keep-${preserve}"
        fi
    done

    find "${FACTORIO_DIR}" -mindepth 1 -maxdepth 1 \
        ! -name 'saves' ! -name 'config' ! -name 'mods' ! -name 'script-output' \
        -exec rm -rf {} +

    shopt -s dotglob nullglob
    local item
    for item in "${extract_dir}/factorio"/*; do
        mv "${item}" "${FACTORIO_DIR}/"
    done
    shopt -u dotglob nullglob
    rm -rf "${extract_dir}"

    for preserve in saves config mods script-output; do
        if [ -e "/tmp/factorio-keep-${preserve}" ]; then
            rm -rf "${FACTORIO_DIR:?}/${preserve}"
            mv "/tmp/factorio-keep-${preserve}" "${FACTORIO_DIR}/${preserve}"
        fi
    done

    if [ -f "${SERVER_BINARY}" ] && [ ! -x "${SERVER_BINARY}" ]; then
        chmod +x "${SERVER_BINARY}"
    fi
    if ! server_binary_present; then
        echo "Factorio install failed: ${SERVER_BINARY} not found" >&2
        exit 1
    fi

    printf '%s\n' "${FACTORIO_VERSION}" > "${VERSION_FILE}"
    echo "--- Factorio installed ---"
}

needs_install() {
    if ! server_binary_present; then
        return 0
    fi
    if [ "${FACTORIO_FORCE_UPDATE}" = "true" ]; then
        return 0
    fi
    if [ ! -f "${VERSION_FILE}" ]; then
        return 0
    fi
    if [ "$(cat "${VERSION_FILE}")" != "${FACTORIO_VERSION}" ]; then
        return 0
    fi
    return 1
}

write_server_settings() {
    local public_vis="false"
    local lan_vis="true"
    local auto_pause="true"
    local name_json description_json password_json

    case "${PUBLIC_VISIBILITY}" in
        true|TRUE|1|yes|YES) public_vis="true" ;;
    esac
    case "${LAN_VISIBILITY}" in
        false|FALSE|0|no|NO) lan_vis="false" ;;
    esac
    case "${AUTO_PAUSE}" in
        false|FALSE|0|no|NO) auto_pause="false" ;;
    esac

    name_json="$(json_escape "${SERVER_NAME}")"
    description_json="$(json_escape "${SERVER_DESCRIPTION}")"
    password_json="$(json_escape "${SERVER_PASSWORD}")"

    cat > "${SETTINGS_FILE}" <<EOF
{
  "name": "${name_json}",
  "description": "${description_json}",
  "tags": ["game", "tags"],
  "max_players": ${MAX_PLAYERS},
  "visibility": {
    "public": ${public_vis},
    "lan": ${lan_vis}
  },
  "username": "",
  "password": "",
  "token": "",
  "game_password": "${password_json}",
  "require_user_verification": true,
  "max_upload_in_kilobytes_per_second": 0,
  "max_upload_slots": 5,
  "minimum_latency_in_ticks": 0,
  "ignore_player_limit_for_returning_players": false,
  "allow_commands": "admins-only",
  "autosave_interval": ${AUTOSAVE_INTERVAL},
  "autosave_slots": 5,
  "afk_autokick_interval": 0,
  "auto_pause": ${auto_pause},
  "only_admins_can_pause_the_game": true,
  "autosave_only_on_server": true,
  "non_blocking_saving": false
}
EOF
}

ensure_config() {
    mkdir -p "${CONFIG_DIR}" "${SAVES_DIR}" "${FACTORIO_DIR}/mods"
    if [ ! -f "${SETTINGS_FILE}" ]; then
        echo "--- Writing default server-settings.json ---"
        write_server_settings
    fi
}

ensure_save() {
    if [ "${LOAD_LATEST}" = "true" ] || [ "${LOAD_LATEST}" = "TRUE" ]; then
        return
    fi
    if [ -f "${SAVE_FILE}" ]; then
        return
    fi
    echo "--- Creating save ${SAVE_FILE} ---"
    "${SERVER_BINARY}" --create "${SAVE_FILE}"
}

if needs_install; then
    install_server
fi

ensure_config
ensure_save

cd "${FACTORIO_DIR}"

args=(
    --server-settings "${SETTINGS_FILE}"
    --port "${PORT}"
    --bind "${BIND}"
)

if [ -n "${RCON_PASSWORD}" ]; then
    args+=(--rcon-port "${RCON_PORT}" --rcon-password "${RCON_PASSWORD}")
fi

if [ "${LOAD_LATEST}" = "true" ] || [ "${LOAD_LATEST}" = "TRUE" ]; then
    args+=(--start-server-load-latest)
else
    args+=(--start-server "${SAVE_FILE}")
fi

# shellcheck disable=SC2206
if [ -n "${FACTORIO_EXTRA_ARGS}" ]; then
    extra=( ${FACTORIO_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting Factorio server on UDP ${PORT} ---"
exec "${SERVER_BINARY}" "${args[@]}"
