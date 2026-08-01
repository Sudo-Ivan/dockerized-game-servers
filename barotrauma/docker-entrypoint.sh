#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${BAROTRAUMA_DIR}"
    chown -R barotrauma:barotrauma "${BAROTRAUMA_DIR}" 2>/dev/null || true
    exec runuser -u barotrauma -- /bin/bash /home/barotrauma/entrypoint.sh "$@"
fi

exec /bin/bash /home/barotrauma/entrypoint.sh "$@"
