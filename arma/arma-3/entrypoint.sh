#!/bin/bash
set -eu

mkdir -p "${ARMA_DIR}/keys"

STEAM_USERNAME="${STEAM_USERNAME:-anonymous}"
STEAM_PASSWORD="${STEAM_PASSWORD:-}"
STEAM_GUARD_CODE="${STEAM_GUARD_CODE:-}"
ARMA_APP_ID="${ARMA_APP_ID:-233780}"

if [ ! -f "${ARMA_DIR}/arma3server_x64" ]; then
    echo "--- Installing Arma 3 server (App ${ARMA_APP_ID}) ---"
    STEAM_LOGIN="${STEAM_USERNAME}"
    if [ -n "${STEAM_PASSWORD}" ]; then
        STEAM_LOGIN="${STEAM_LOGIN} ${STEAM_PASSWORD}"
    fi
    if [ -n "${STEAM_GUARD_CODE}" ]; then
        STEAM_LOGIN="${STEAM_LOGIN} ${STEAM_GUARD_CODE}"
    fi
    # shellcheck disable=SC2086
    ${STEAM_DIR}/steamcmd.sh +force_install_dir ${ARMA_DIR} +login ${STEAM_LOGIN} +app_update ${ARMA_APP_ID} validate +quit
fi

if [ ! -f "${ARMA_DIR}/arma3server_x64" ]; then
    echo "Arma 3 server binary not found at ${ARMA_DIR}/arma3server_x64" >&2
    echo "Anonymous Steam login cannot download Arma 3. Set STEAM_USERNAME and STEAM_PASSWORD for an account that owns the server." >&2
    exit 1
fi

MOD_LIST=""
MODLIST_FILE="${MODLIST_FILE:-${ARMA_DIR}/modlist.html}"

if [ -f "${MODLIST_FILE}" ]; then
    echo "--- Syncing workshop mods from ${MODLIST_FILE} (Steam CDN) ---"
    if ! WORKSHOP_IDS=$(python3 /home/arma3/sync_mods.py "${MODLIST_FILE}"); then
        echo "Workshop sync failed."
        exit 1
    fi

    for MOD_ID in $WORKSHOP_IDS; do
        MOD_PATH="${ARMA_DIR}/workshop/${MOD_ID}"

        if [ -d "$MOD_PATH" ]; then
            ln -sfn "$MOD_PATH" "${ARMA_DIR}/@${MOD_ID}"

            if [ -z "$MOD_LIST" ]; then
                MOD_LIST="@${MOD_ID}"
            else
                MOD_LIST="${MOD_LIST};@${MOD_ID}"
            fi
        fi
    done
fi

if [ -n "${CDLC:-}" ]; then
    echo "--- Adding Creator DLCs: $CDLC ---"
    if [ -z "$MOD_LIST" ]; then
        MOD_LIST="${CDLC}"
    else
        MOD_LIST="${MOD_LIST};${CDLC}"
    fi
fi

if [ -n "${EXTRA_MODS:-}" ]; then
    if [ -z "$MOD_LIST" ]; then
        MOD_LIST="${EXTRA_MODS}"
    else
        MOD_LIST="${MOD_LIST};${EXTRA_MODS}"
    fi
fi

echo "--- Starting Arma 3 with mods: $MOD_LIST ---"

chmod +x "${ARMA_DIR}/arma3server_x64"

cd "${ARMA_DIR}"
exec ./arma3server_x64 \
    -config=/home/arma3/configs/server.cfg \
    -port=2302 \
    -name=server \
    -profiles=/home/arma3/profiles \
    -mod="${MOD_LIST}" \
    -world=empty \
    -noSound \
    -filePatching
