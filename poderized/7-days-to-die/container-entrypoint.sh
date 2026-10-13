#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${SEVENDTD_DIR}" /home/sevendtd/Steam
    chown -R sevendtd:sevendtd "${SEVENDTD_DIR}" /home/sevendtd
    exec runuser -u sevendtd -- /bin/bash /home/sevendtd/entrypoint.sh "$@"
fi

exec /bin/bash /home/sevendtd/entrypoint.sh "$@"
