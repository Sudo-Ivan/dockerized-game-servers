#!/bin/bash
set -eu
if [ "$(id -u)" = "0" ]; then
    mkdir -p "${BF1942_DIR}"
    chown -R bf1942:bf1942 "${BF1942_DIR}" 2>/dev/null || true
    exec runuser -u bf1942 -- /bin/bash /home/bf1942/entrypoint.sh "$@"
fi
exec /bin/bash /home/bf1942/entrypoint.sh "$@"
