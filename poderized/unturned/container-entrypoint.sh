#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${UNTURNED_DIR}"
    chown -R unturned:unturned "${UNTURNED_DIR}" 2>/dev/null || true
    exec runuser -u unturned -- /bin/bash /home/unturned/entrypoint.sh "$@"
fi

exec /bin/bash /home/unturned/entrypoint.sh "$@"
