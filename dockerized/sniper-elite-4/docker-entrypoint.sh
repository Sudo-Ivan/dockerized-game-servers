#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${SE4_DIR}"
    chown -R se4:se4 "${SE4_DIR}" 2>/dev/null || true
    exec runuser -u se4 -- /bin/bash /home/se4/entrypoint.sh "$@"
fi

exec /bin/bash /home/se4/entrypoint.sh "$@"
