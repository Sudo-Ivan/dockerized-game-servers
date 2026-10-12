#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${RTCWCOOP_DIR}"
    chown -R rtcwcoop:rtcwcoop "${RTCWCOOP_DIR}" 2>/dev/null || true
    exec runuser -u rtcwcoop -- /bin/bash /home/rtcwcoop/entrypoint.sh "$@"
fi

exec /bin/bash /home/rtcwcoop/entrypoint.sh "$@"
