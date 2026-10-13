#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${FOREST_DIR}" /home/theforest/Steam
    chown -R theforest:theforest "${FOREST_DIR}" /home/theforest
    exec runuser -u theforest -- /bin/bash /home/theforest/entrypoint.sh "$@"
fi

exec /bin/bash /home/theforest/entrypoint.sh "$@"
