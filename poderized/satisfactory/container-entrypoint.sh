#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${SATISFACTORY_DIR}" /home/satisfactory/Steam
    chown -R satisfactory:satisfactory "${SATISFACTORY_DIR}" /home/satisfactory
    exec runuser -u satisfactory -- /bin/bash /home/satisfactory/entrypoint.sh "$@"
fi

exec /bin/bash /home/satisfactory/entrypoint.sh "$@"
