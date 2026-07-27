#!/bin/bash
set -eu
if [ "$(id -u)" = "0" ]; then
    mkdir -p "${BFV_DIR}"
    chown -R bfv:bfv "${BFV_DIR}" 2>/dev/null || true
    exec runuser -u bfv -- /bin/bash /home/bfv/entrypoint.sh "$@"
fi
exec /bin/bash /home/bfv/entrypoint.sh "$@"
