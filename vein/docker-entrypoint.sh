#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${VEIN_DIR}" /tmp/.X11-unix
    chmod 1777 /tmp/.X11-unix 2>/dev/null || true
    chown -R vein:vein "${VEIN_DIR}" 2>/dev/null || true
    exec runuser -u vein -- /bin/bash /home/vein/entrypoint.sh "$@"
fi

exec /bin/bash /home/vein/entrypoint.sh "$@"
