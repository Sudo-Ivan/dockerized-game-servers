#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${TERRARIA_DIR}" /home/terraria/Steam
    chown -R terraria:terraria "${TERRARIA_DIR}" /home/terraria
    exec runuser -u terraria -- /bin/bash /home/terraria/entrypoint.sh "$@"
fi

exec /bin/bash /home/terraria/entrypoint.sh "$@"
