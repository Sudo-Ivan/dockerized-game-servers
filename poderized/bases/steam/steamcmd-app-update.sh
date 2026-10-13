# Shared SteamCMD helpers for Linux dedicated server installs.
# shellcheck shell=bash

steam_login_args() {
    local steam_login="${STEAM_USERNAME:-anonymous}"
    if [ -n "${STEAM_PASSWORD:-}" ]; then
        steam_login="${steam_login} ${STEAM_PASSWORD}"
    fi
    if [ -n "${STEAM_GUARD_CODE:-}" ]; then
        steam_login="${steam_login} ${STEAM_GUARD_CODE}"
    fi
    printf '%s' "${steam_login}"
}

steamcmd_resolve_bin() {
    if [ -n "${STEAMCMD_BIN:-}" ] && [ -x "${STEAMCMD_BIN}" ]; then
        printf '%s' "${STEAMCMD_BIN}"
        return 0
    fi
    if [ -x "${STEAM_DIR}/linux32/steamcmd" ]; then
        printf '%s' "${STEAM_DIR}/linux32/steamcmd"
        return 0
    fi
    if [ -f "${STEAM_DIR}/steamcmd.sh" ]; then
        printf '%s' "${STEAM_DIR}/steamcmd.sh"
        return 0
    fi
    echo "steamcmd not found under STEAM_DIR=${STEAM_DIR}" >&2
    return 1
}

steam_prepare_install_dir() {
    local install_dir="${1}"
    mkdir -p "${install_dir}/steamapps"
    cat > "${install_dir}/steamapps/libraryfolders.vdf" <<EOF
"LibraryFolders"
{
    "0" "${install_dir}"
}
EOF
}

steam_cleanup_incomplete_install() {
    local install_dir="${1}"
    local app_id="${2}"
    local ready_path="${3}"

    if [ -f "${ready_path}" ]; then
        return 0
    fi
    if [ -f "${install_dir}/steamapps/appmanifest_${app_id}.acf" ]; then
        echo "--- Resuming Steam install in ${install_dir} ---"
        return 0
    fi
    if [ -d "${install_dir}/steamapps" ]; then
        echo "--- Removing incomplete Steam install state from ${install_dir} ---"
        rm -rf "${install_dir}/steamapps" "${install_dir}/package"
    fi
}

steamcmd_invoke() {
    local platform="${1}"
    local install_dir="${2}"
    shift 2
    local steamcmd_bin
    steamcmd_bin="$(steamcmd_resolve_bin)"
    local steam_login
    steam_login="$(steam_login_args)"
    local status=0
    while true; do
        # shellcheck disable=SC2086
        "${steamcmd_bin}" \
            +@sSteamCmdForcePlatformType "${platform}" \
            +force_install_dir "${install_dir}" \
            +login ${steam_login} \
            "$@" \
            +quit
        status=$?
        if [ "${status}" -ne 42 ]; then
            break
        fi
    done
    return "${status}"
}

steamcmd_prime_windows() {
    local install_dir="${1}"
    local steamcmd_bin
    steamcmd_bin="$(steamcmd_resolve_bin)"
    local steam_login
    steam_login="$(steam_login_args)"
    # shellcheck disable=SC2086
    "${steamcmd_bin}" \
        +@sSteamCmdForcePlatformType windows \
        +force_install_dir "${install_dir}" \
        +login ${steam_login} \
        +quit || true
}

steamcmd_install_linux_app() {
    local install_dir="${1}"
    local primary_app_id="${2}"
    shift 2
    local mode="${STEAMCMD_WINDOWS_WORKAROUND:-prime}"
    local status=0

    export LD_LIBRARY_PATH="${STEAM_DIR}/linux32:${LD_LIBRARY_PATH:-}"

    case "${mode}" in
        full)
            echo "--- SteamCMD: fetching Windows depot (workaround for App ${primary_app_id}) ---"
            steamcmd_invoke windows "${install_dir}" +app_update "${primary_app_id}" validate || status=$?
            if [ "${status}" -ne 0 ]; then
                return "${status}"
            fi
            echo "--- SteamCMD: fetching Linux depot for App ${primary_app_id} ---"
            steamcmd_invoke linux "${install_dir}" "$@" || status=$?
            ;;
        off)
            steamcmd_invoke linux "${install_dir}" "$@" || status=$?
            ;;
        prime|*)
            steamcmd_prime_windows "${install_dir}"
            steamcmd_invoke linux "${install_dir}" "$@" || status=$?
            ;;
    esac
    return "${status}"
}

steam_install_anonymous_hint() {
    local app_id="${1}"
    local game_label="${2:-this dedicated server}"
    if [ "${STEAM_USERNAME:-anonymous}" = "anonymous" ]; then
        echo "Anonymous Steam login may not download App ${app_id}. Set STEAM_USERNAME and STEAM_PASSWORD for an account entitled to ${game_label}." >&2
    else
        echo "Confirm the Steam account is entitled to ${game_label}. For Steam Guard use STEAM_GUARD_CODE or an app password." >&2
    fi
}
