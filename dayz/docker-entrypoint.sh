#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${DAYZ_DIR}"
    chown -R dayz:dayz "${DAYZ_DIR}" 2>/dev/null || true
    exec runuser -u dayz -- /bin/bash /home/dayz/entrypoint.sh "$@"
fi

exec /bin/bash /home/dayz/entrypoint.sh "$@"
