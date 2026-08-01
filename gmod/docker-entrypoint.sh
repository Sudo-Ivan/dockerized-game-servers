#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${GMOD_DIR}"
    chown -R gmod:gmod "${GMOD_DIR}" 2>/dev/null || true
    exec runuser -u gmod -- /bin/bash /home/gmod/entrypoint.sh "$@"
fi

exec /bin/bash /home/gmod/entrypoint.sh "$@"
