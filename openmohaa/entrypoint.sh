#!/bin/bash
set -eu

OPENMOHAA_VERSION="${OPENMOHAA_VERSION:-v0.82.1}"
OPENMOHAA_FORCE_UPDATE="${OPENMOHAA_FORCE_UPDATE:-false}"
MOH_GAME_PORT="${MOH_GAME_PORT:-12203}"
MOH_GAMESPY_PORT="${MOH_GAMESPY_PORT:-12300}"
MOH_TARGET_GAME="${MOH_TARGET_GAME:-0}"
MOH_SERVER_CFG="${MOH_SERVER_CFG:-server.cfg}"
MOH_EXTRA_ARGS="${MOH_EXTRA_ARGS:-}"

SERVER_BIN="${MOHAA_INSTALL_DIR}/lib/openmohaa/omohaaded"
VERSION_FILE="${MOHAA_INSTALL_DIR}/.installed-version"
SETTINGS_DIR="${MOHAA_DATA_DIR}/home/main/settings"
DEFAULT_CFG="${SETTINGS_DIR}/${MOH_SERVER_CFG}"

pk3_present() {
    local dir="$1"
    if [ ! -d "${dir}" ]; then
        return 1
    fi
    compgen -G "${dir}"/*.pk3 >/dev/null \
        || compgen -G "${dir}"/*.PK3 >/dev/null \
        || compgen -G "${dir}"/Pak*.pk3 >/dev/null \
        || compgen -G "${dir}"/pak*.pk3 >/dev/null
}

require_game_assets() {
    local ok=0
    if pk3_present "${MOHAA_DATA_DIR}/main"; then
        ok=1
    fi
    if pk3_present "${MOHAA_DATA_DIR}/mainta"; then
        ok=1
    fi
    if pk3_present "${MOHAA_DATA_DIR}/maintt"; then
        ok=1
    fi
    if [ "${ok}" -eq 0 ]; then
        cat >&2 <<EOF
OpenMoHAA needs your owned Medal of Honor: Allied Assault game data.

Copy main, mainta, and maintt from your install into:
  ${MOHAA_DATA_DIR}

Expected layout (sound and video folders are not required):
  main/Pak*.pk3
  mainta/pak*.pk3
  maintt/pak*.pk3

With the default compose volume, place those folders under openmohaa/data/.
See https://docs.openmohaa.org/ and the server page in this repo.
EOF
        exit 1
    fi
}

install_openmohaa() {
    echo "--- Installing OpenMoHAA ${OPENMOHAA_VERSION} ---"
    local archive="/tmp/openmohaa.zip"
    local install_dir="${MOHAA_INSTALL_DIR}/lib/openmohaa"

    # shellcheck source=/usr/local/bin/http-download.sh
    . /usr/local/bin/http-download.sh
    http_download_file \
        "https://github.com/openmoh/openmohaa/releases/download/${OPENMOHAA_VERSION}/openmohaa-${OPENMOHAA_VERSION}-linux-amd64.zip" \
        "${archive}"

    rm -rf "${install_dir}"
    mkdir -p "${install_dir}"
    unzip -q "${archive}" -d "${install_dir}"
    chmod +x "${install_dir}/omohaaded"
    rm -f "${archive}"
    printf '%s\n' "${OPENMOHAA_VERSION}" > "${VERSION_FILE}"
    echo "--- OpenMoHAA installed ---"
}

needs_install() {
    if [ ! -x "${SERVER_BIN}" ]; then
        return 0
    fi
    if [ "${OPENMOHAA_FORCE_UPDATE}" = "true" ]; then
        return 0
    fi
    if [ ! -f "${VERSION_FILE}" ]; then
        return 0
    fi
    if [ "$(cat "${VERSION_FILE}")" != "${OPENMOHAA_VERSION}" ]; then
        return 0
    fi
    return 1
}

ensure_server_cfg() {
  mkdir -p "${SETTINGS_DIR}"
  if [ -f "${DEFAULT_CFG}" ]; then
    return
  fi
  echo "--- Writing default ${MOH_SERVER_CFG} ---"
  cat > "${DEFAULT_CFG}" <<'EOF'
set sv_hostname "OpenMoHAA Server"
set sv_maxclients 16
set g_gametype 0
map mohdm1
EOF
}

if needs_install; then
    install_openmohaa
fi

require_game_assets
ensure_server_cfg

export LD_LIBRARY_PATH="${MOHAA_INSTALL_DIR}/lib/openmohaa:${LD_LIBRARY_PATH:-}"

cd "${MOHAA_DATA_DIR}"

args=(
    +set fs_homepath home
    +set dedicated 2
    +set net_port "${MOH_GAME_PORT}"
    +set net_gamespy_port "${MOH_GAMESPY_PORT}"
)

if [ -n "${MOH_TARGET_GAME}" ]; then
    args+=(+set com_target_game "${MOH_TARGET_GAME}")
fi

if [ -n "${MOH_SERVER_CFG}" ] && [ -f "${DEFAULT_CFG}" ]; then
    args+=(+exec "${MOH_SERVER_CFG}")
fi

if [ -n "${MOH_EXTRA_ARGS}" ]; then
    # shellcheck disable=SC2206
    extra=( ${MOH_EXTRA_ARGS} )
    args+=("${extra[@]}")
fi

if [ "$#" -gt 0 ]; then
    args+=("$@")
fi

echo "--- Starting OpenMoHAA dedicated server on UDP ${MOH_GAME_PORT} ---"
exec "${SERVER_BIN}" "${args[@]}"
