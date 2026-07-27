#!/bin/bash
set -eu

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
VALHEIM_APP_ID="${VALHEIM_APP_ID:-896660}"
VALHEIM_FORCE_UPDATE="${VALHEIM_FORCE_UPDATE:-false}"
VALHEIM_PLUS_VERSION="${VALHEIM_PLUS_VERSION:-0.9.17.1}"
VALHEIM_PLUS_FORCE_INSTALL="${VALHEIM_PLUS_FORCE_INSTALL:-false}"

SERVER_NAME="${SERVER_NAME:-Valheim Plus Server}"
SERVER_PORT="${SERVER_PORT:-2456}"
WORLD_NAME="${WORLD_NAME:-Dedicated}"
SERVER_PASS="${SERVER_PASS:-secret}"
SERVER_PUBLIC="${SERVER_PUBLIC:-1}"
SERVER_LOGINTOKEN="${SERVER_LOGINTOKEN:-}"

VALHEIM_PLUS_URL="${VALHEIM_PLUS_URL:-https://github.com/Grantapher/ValheimPlus/releases/download/${VALHEIM_PLUS_VERSION}/UnixServer.tar.gz}"
VALHEIM_PLUS_MARKER="${VALHEIM_DIR}/.valheim-plus-version"

SERVER_BINARY="${VALHEIM_DIR}/valheim_server.x86_64"

server_binary_present() {
    [ -f "${SERVER_BINARY}" ]
}

prepare_steam_install_dir() {
    mkdir -p "${VALHEIM_DIR}/steamapps"
    cat > "${VALHEIM_DIR}/steamapps/libraryfolders.vdf" <<EOF
"LibraryFolders"
{
    "0" "${VALHEIM_DIR}"
}
EOF
}

cleanup_incomplete_install() {
    if [ -d "${VALHEIM_DIR}/steamapps" ] && ! server_binary_present; then
        echo "--- Removing incomplete Steam install state from ${VALHEIM_DIR} ---"
        rm -rf "${VALHEIM_DIR}/steamapps" "${VALHEIM_DIR}/package"
    fi
}

relocate_install_if_needed() {
    if server_binary_present; then
        return
    fi

    local alt_dir=""
    while IFS= read -r alt_dir; do
        if [ -f "${alt_dir}/valheim_server.x86_64" ]; then
            echo "--- Moving server files from ${alt_dir} to ${VALHEIM_DIR} ---"
            shopt -s dotglob nullglob
            local item
            for item in "${alt_dir}"/*; do
                base="$(basename "${item}")"
                if [ ! -e "${VALHEIM_DIR}/${base}" ]; then
                    mv "${item}" "${VALHEIM_DIR}/"
                fi
            done
            shopt -u dotglob nullglob
            return
        fi
    done < <(find /home/valheim/Steam/steamapps/common -mindepth 1 -maxdepth 1 -type d 2>/dev/null)
}

install_server() {
    echo "--- Installing Valheim dedicated server (App ${VALHEIM_APP_ID}) ---"
    mkdir -p "${VALHEIM_DIR}"
    cleanup_incomplete_install
    prepare_steam_install_dir

    local steam_login="${STEAM_USERNAME}"
    if [ -n "${STEAM_PASSWORD}" ]; then
        steam_login="${steam_login} ${STEAM_PASSWORD}"
    fi
    export LD_LIBRARY_PATH="${STEAM_DIR}/linux32:${LD_LIBRARY_PATH:-}"
    local status=0
    while true; do
        # steam_login may contain "user pass" as two argv words for steamcmd
        # shellcheck disable=SC2086
        "${STEAM_DIR}/linux32/steamcmd" \
            +@sSteamCmdForcePlatformType linux \
            +force_install_dir "${VALHEIM_DIR}" \
            +login ${steam_login} \
            +app_update "${VALHEIM_APP_ID}" validate \
            +quit
        status=$?
        if [ "${status}" -ne 42 ]; then
            break
        fi
    done
    if [ "${status}" -ne 0 ]; then
        echo "Valheim server install failed with exit code ${status}" >&2
        exit 1
    fi

    relocate_install_if_needed

    if ! server_binary_present; then
        echo "Valheim server install failed: ${SERVER_BINARY} not found after Steam reported success." >&2
        echo "Contents of ${VALHEIM_DIR}:" >&2
        ls -la "${VALHEIM_DIR}" >&2 || true
        exit 1
    fi
}

install_valheim_plus() {
    local installed_version=""
    if [ -f "${VALHEIM_PLUS_MARKER}" ]; then
        installed_version="$(tr -d '[:space:]' < "${VALHEIM_PLUS_MARKER}")"
    fi

    if [ -f "${VALHEIM_DIR}/start_server_bepinex.sh" ] \
        && [ "${installed_version}" = "${VALHEIM_PLUS_VERSION}" ] \
        && [ "${VALHEIM_PLUS_FORCE_INSTALL}" != "true" ]; then
        return
    fi

    echo "--- Installing Valheim Plus ${VALHEIM_PLUS_VERSION} ---"
    curl -fsSL "${VALHEIM_PLUS_URL}" -o /tmp/valheim-plus.tar.gz
    tar -xzf /tmp/valheim-plus.tar.gz -C "${VALHEIM_DIR}"
    rm -f /tmp/valheim-plus.tar.gz
    chmod +x "${VALHEIM_DIR}/start_server_bepinex.sh"
    printf '%s\n' "${VALHEIM_PLUS_VERSION}" > "${VALHEIM_PLUS_MARKER}"
}

if ! server_binary_present || [ "${VALHEIM_FORCE_UPDATE}" = "true" ]; then
    install_server
fi

install_valheim_plus

cd "${VALHEIM_DIR}"

args=(
    -name "${SERVER_NAME}"
    -port "${SERVER_PORT}"
    -world "${WORLD_NAME}"
    -password "${SERVER_PASS}"
    -public "${SERVER_PUBLIC}"
)

if [ -n "${SERVER_LOGINTOKEN}" ]; then
    args+=(-crossplay -logintoken "${SERVER_LOGINTOKEN}")
fi

export LD_LIBRARY_PATH="${VALHEIM_DIR}/linux64:${LD_LIBRARY_PATH:-}"

echo "--- Starting Valheim Plus server: ${SERVER_NAME} ---"
exec ./start_server_bepinex.sh "${args[@]}"
