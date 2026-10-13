#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${COD_DIR}"
    chown -R cod:cod "${COD_DIR}" 2>/dev/null || true
    exec runuser -u cod -- /bin/bash /home/cod/entrypoint.sh "$@"
fi

exec /bin/bash /home/cod/entrypoint.sh "$@"
