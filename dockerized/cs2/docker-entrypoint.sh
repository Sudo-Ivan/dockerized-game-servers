#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${CS2_DIR}"
    chown -R cs2:cs2 "${CS2_DIR}" 2>/dev/null || true
    exec runuser -u cs2 -- /bin/bash /home/cs2/entrypoint.sh "$@"
fi

exec /bin/bash /home/cs2/entrypoint.sh "$@"
