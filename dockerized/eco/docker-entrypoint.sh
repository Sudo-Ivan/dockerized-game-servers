#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${ECO_DIR}"
    chown -R eco:eco "${ECO_DIR}" 2>/dev/null || true
    exec runuser -u eco -- /bin/bash /home/eco/entrypoint.sh "$@"
fi

exec /bin/bash /home/eco/entrypoint.sh "$@"
