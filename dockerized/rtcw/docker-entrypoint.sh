#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${RTCW_DIR}"
    chown -R rtcw:rtcw "${RTCW_DIR}" 2>/dev/null || true
    exec runuser -u rtcw -- /bin/bash /home/rtcw/entrypoint.sh "$@"
fi

exec /bin/bash /home/rtcw/entrypoint.sh "$@"
