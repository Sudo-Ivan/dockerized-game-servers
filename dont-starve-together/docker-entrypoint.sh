#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${DST_DIR}" /home/dst/Steam
    chown -R dst:dst "${DST_DIR}" /home/dst
    exec runuser -u dst -- /bin/bash /home/dst/entrypoint.sh "$@"
fi

exec /bin/bash /home/dst/entrypoint.sh "$@"
