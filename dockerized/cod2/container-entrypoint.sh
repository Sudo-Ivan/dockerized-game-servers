#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${COD2_DIR}"
    chown -R cod2:cod2 "${COD2_DIR}" 2>/dev/null || true
    exec runuser -u cod2 -- /bin/bash /home/cod2/entrypoint.sh "$@"
fi

exec /bin/bash /home/cod2/entrypoint.sh "$@"
