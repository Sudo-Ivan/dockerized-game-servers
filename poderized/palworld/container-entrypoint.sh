#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${PALWORLD_DIR}" /home/palworld/Steam
    chown -R palworld:palworld "${PALWORLD_DIR}" /home/palworld
    exec runuser -u palworld -- /bin/bash /home/palworld/entrypoint.sh "$@"
fi

exec /bin/bash /home/palworld/entrypoint.sh "$@"
