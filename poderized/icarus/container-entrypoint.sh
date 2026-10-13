#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${ICARUS_DIR}"
    chown -R icarus:icarus "${ICARUS_DIR}" 2>/dev/null || true
    exec runuser -u icarus -- /bin/bash /home/icarus/entrypoint.sh "$@"
fi

exec /bin/bash /home/icarus/entrypoint.sh "$@"
