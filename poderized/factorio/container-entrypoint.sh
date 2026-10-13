#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${FACTORIO_DIR}"
    chown -R factorio:factorio "${FACTORIO_DIR}" /home/factorio
    exec runuser -u factorio -- /bin/bash /home/factorio/entrypoint.sh "$@"
fi

exec /bin/bash /home/factorio/entrypoint.sh "$@"
