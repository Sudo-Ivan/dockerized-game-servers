#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${VS_ROOT}" "${VS_SERVER_DIR}" "${VS_DATA_DIR}"
    chown -R vintagestory:vintagestory "${VS_ROOT}" /home/vintagestory 2>/dev/null || true
    exec runuser -u vintagestory -- /bin/bash /home/vintagestory/entrypoint.sh "$@"
fi

mkdir -p "${VS_ROOT}" "${VS_SERVER_DIR}" "${VS_DATA_DIR}"
exec /bin/bash /home/vintagestory/entrypoint.sh "$@"
