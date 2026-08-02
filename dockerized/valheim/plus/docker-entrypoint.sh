#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${VALHEIM_DIR}" /home/valheim/Steam
    chown -R valheim:valheim "${VALHEIM_DIR}" /home/valheim
    exec runuser -u valheim -- /bin/bash /home/valheim/entrypoint.sh "$@"
fi

exec /bin/bash /home/valheim/entrypoint.sh "$@"
