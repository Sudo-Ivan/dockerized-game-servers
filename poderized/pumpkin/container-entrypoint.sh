#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${PUMPKIN_DIR}"
    chown -R pumpkin:pumpkin "${PUMPKIN_DIR}" 2>/dev/null || true
    exec runuser -u pumpkin -- /bin/bash /home/pumpkin/entrypoint.sh "$@"
fi

exec /bin/bash /home/pumpkin/entrypoint.sh "$@"
