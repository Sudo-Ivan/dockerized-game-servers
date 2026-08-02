#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${ENSHROUDED_DIR}" /tmp/.X11-unix
    chmod 1777 /tmp/.X11-unix 2>/dev/null || true
    chown -R enshrouded:enshrouded "${ENSHROUDED_DIR}" 2>/dev/null || true
    exec runuser -u enshrouded -- /bin/bash /home/enshrouded/entrypoint.sh "$@"
fi

exec /bin/bash /home/enshrouded/entrypoint.sh "$@"
