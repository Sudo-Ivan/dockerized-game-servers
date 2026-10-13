#!/bin/bash
# Core Keeper ready helpers (sourced by entrypoint, testable offline).

# shellcheck shell=bash

ck_ready_bold_cyan() {
    local text="$1"
    printf '\033[1;36m%s\033[0m\n' "${text}"
}

ck_ready_bold_green() {
    local text="$1"
    printf '\033[1;32m%s\033[0m\n' "${text}"
}

ck_print_game_id() {
    local game_id="$1"
    ck_ready_bold_cyan "Game ID: ${game_id}"
}

ck_print_ready_status() {
    ck_ready_bold_green "Status: server is up and ready for players!"
}

# Poll GameID.txt until non-empty. Args: path, timeout_seconds, optional pid to watch.
ck_wait_for_game_id() {
    local game_id_file="$1"
    local timeout_seconds="${2:-120}"
    local watch_pid="${3:-}"
    local elapsed=0
    local game_id=""

    while [ "${elapsed}" -lt "${timeout_seconds}" ]; do
        if [ -n "${watch_pid}" ] && ! kill -0 "${watch_pid}" 2>/dev/null; then
            echo "Core Keeper process exited before Game ID was ready" >&2
            return 1
        fi
        if [ -f "${game_id_file}" ]; then
            game_id="$(tr -d '\r\n' < "${game_id_file}" || true)"
            if [ -n "${game_id}" ]; then
                printf '%s\n' "${game_id}"
                return 0
            fi
        fi
        sleep 1
        elapsed=$((elapsed + 1))
    done

    echo "Timed out waiting for Game ID at ${game_id_file}" >&2
    return 1
}
