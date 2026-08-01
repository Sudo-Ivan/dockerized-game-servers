#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${TF2_DIR}"
    chown -R tf2:tf2 "${TF2_DIR}" 2>/dev/null || true
    exec runuser -u tf2 -- /bin/bash /home/tf2/entrypoint.sh "$@"
fi

exec /bin/bash /home/tf2/entrypoint.sh "$@"
