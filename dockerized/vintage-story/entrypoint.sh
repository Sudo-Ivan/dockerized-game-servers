#!/bin/bash
set -eu

VS_VERSION="${VS_VERSION:-1.22.6}"
VS_BRANCH="${VS_BRANCH:-stable}"
VS_FORCE_UPDATE="${VS_FORCE_UPDATE:-false}"
VS_DOWNLOAD_URL="${VS_DOWNLOAD_URL:-https://cdn.vintagestory.at/gamefiles/${VS_BRANCH}/vs_server_linux-x64_${VS_VERSION}.tar.gz}"

PORT="${PORT:-42420}"
BIND="${BIND:-0.0.0.0}"
MAX_PLAYERS="${MAX_PLAYERS:-16}"
SERVER_PASSWORD="${SERVER_PASSWORD:-}"
VS_EXTRA_ARGS="${VS_EXTRA_ARGS:-}"

SERVER_DLL="${VS_SERVER_DIR}/VintagestoryServer.dll"
VERSION_FILE="${VS_ROOT}/.installed-version"
CONFIG_FILE="${VS_DATA_DIR}/serverconfig.json"

server_present() {
    [ -f "${SERVER_DLL}" ]
}

install_server() {
    echo "--- Installing Vintage Story server (${VS_VERSION}, ${VS_BRANCH}) ---"
    local archive="/tmp/vintage-story-server.tar.gz"
    local extract_dir="/tmp/vintage-story-extract"

    rm -rf "${extract_dir}"
    mkdir -p "${extract_dir}" "${VS_SERVER_DIR}"

    # shellcheck source=dockerized/bases/runtime/http-download.sh
    . /usr/local/bin/http-download.sh
    http_download_file "${VS_DOWNLOAD_URL}" "${archive}"

    tar -xzf "${archive}" -C "${extract_dir}"
    rm -f "${archive}"

    if [ ! -f "${extract_dir}/VintagestoryServer.dll" ]; then
        echo "Vintage Story archive layout unexpected. Contents:" >&2
        find "${extract_dir}" -maxdepth 2 -print >&2 || true
        exit 1
    fi

    find "${VS_SERVER_DIR}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +

    shopt -s dotglob nullglob
    local item
    for item in "${extract_dir}"/*; do
        mv "${item}" "${VS_SERVER_DIR}/"
    done
    shopt -u dotglob nullglob
    rm -rf "${extract_dir}"

    if [ -f "${VS_SERVER_DIR}/server.sh" ]; then
        chmod +x "${VS_SERVER_DIR}/server.sh"
    fi
    if [ -f "${VS_SERVER_DIR}/VintagestoryServer" ]; then
        chmod +x "${VS_SERVER_DIR}/VintagestoryServer"
    fi

    if ! server_present; then
        echo "Vintage Story install failed: ${SERVER_DLL} not found" >&2
        exit 1
    fi

    printf '%s\n' "${VS_VERSION}" > "${VERSION_FILE}"
    echo "--- Vintage Story server installed ---"
}

needs_install() {
    if ! server_present; then
        return 0
    fi
    if [ "${VS_FORCE_UPDATE}" = "true" ]; then
        return 0
    fi
    if [ ! -f "${VERSION_FILE}" ]; then
        return 0
    fi
    if [ "$(cat "${VERSION_FILE}")" != "${VS_VERSION}" ]; then
        return 0
    fi
    return 1
}

ensure_data_dir() {
    mkdir -p "${VS_DATA_DIR}"
}

shell_single_quoted() {
    local s="$1"
    s="${s//\'/\'\\\'\'}"
    printf "'%s'" "${s}"
}

build_withconfig() {
    local parts=()
    local advertise="false"
    local name description motd password

    case "${ADVERTISE_SERVER:-false}" in
        true|TRUE|1|yes|YES) advertise="true" ;;
    esac

    name="$(shell_single_quoted "${SERVER_NAME:-Vintage Story Server}")"
    description="$(shell_single_quoted "${SERVER_DESCRIPTION:-Vintage Story dedicated server}")"
    motd="$(shell_single_quoted "${SERVER_MOTD:-Welcome {0}, may you survive well and prosper}")"

    parts+=("ServerName: ${name}")
    parts+=("ServerDescription: ${description}")
    parts+=("WelcomeMessage: ${motd}")
    parts+=("AdvertiseServer: ${advertise}")

    if [ -n "${SERVER_PASSWORD}" ]; then
        password="$(shell_single_quoted "${SERVER_PASSWORD}")"
        parts+=("Password: ${password}")
    fi

    local joined=""
    local part
    for part in "${parts[@]}"; do
        if [ -n "${joined}" ]; then
            joined="${joined}, ${part}"
        else
            joined="${part}"
        fi
    done
    printf '%s' "{ ${joined} }"
}

if needs_install; then
    install_server
fi

ensure_data_dir

cd "${VS_SERVER_DIR}"

args=(
    "${SERVER_DLL}"
    --dataPath "${VS_DATA_DIR}"
    --port "${PORT}"
    --maxclients "${MAX_PLAYERS}"
)

if [ -n "${BIND}" ] && [ "${BIND}" != "0.0.0.0" ]; then
    args+=(--ip "${BIND}")
fi

if [ ! -f "${CONFIG_FILE}" ]; then
    withconfig="$(build_withconfig)"
    args+=(--withconfig="${withconfig}")
fi

# shellcheck disable=SC2206
if [ -n "${VS_EXTRA_ARGS}" ]; then
    extra=( ${VS_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

echo "--- Starting Vintage Story server on TCP/UDP ${PORT} ---"
exec dotnet "${args[@]}"
