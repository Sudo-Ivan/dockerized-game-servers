#!/bin/bash
set -eu
if [ "$(id -u)" = "0" ]; then
    mkdir -p "${COD4_DIR}"
    chown -R cod4:cod4 "${COD4_DIR}" 2>/dev/null || true
    exec runuser -u cod4 -- /bin/bash /home/cod4/entrypoint.sh "$@"
fi
exec /bin/bash /home/cod4/entrypoint.sh "$@"
