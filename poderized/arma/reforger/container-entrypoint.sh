#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${ARMAR_DIR}"
    chown -R armar:armar "${ARMAR_DIR}" 2>/dev/null || true
    exec runuser -u armar -- /bin/bash /home/armar/entrypoint.sh "$@"
fi

exec /bin/bash /home/armar/entrypoint.sh "$@"
