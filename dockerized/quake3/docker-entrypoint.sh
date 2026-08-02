#!/bin/bash
set -eu
if [ "$(id -u)" = "0" ]; then
    mkdir -p "${Q3_DIR}"
    chown -R quake3:quake3 "${Q3_DIR}" 2>/dev/null || true
    exec runuser -u quake3 -- /bin/bash /home/quake3/entrypoint.sh "$@"
fi
exec /bin/bash /home/quake3/entrypoint.sh "$@"
