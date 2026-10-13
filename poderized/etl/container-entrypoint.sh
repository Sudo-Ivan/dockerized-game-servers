#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${ETL_DIR}"
    chown -R etl:etl "${ETL_DIR}" 2>/dev/null || true
    exec runuser -u etl -- /bin/bash /home/etl/entrypoint.sh "$@"
fi

exec /bin/bash /home/etl/entrypoint.sh "$@"
