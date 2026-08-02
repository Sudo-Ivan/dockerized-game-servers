#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${LONGVINTER_DIR}"
    chown -R longvinter:longvinter "${LONGVINTER_DIR}" 2>/dev/null || true
    exec runuser -u longvinter -- /bin/bash /home/longvinter/entrypoint.sh "$@"
fi

exec /bin/bash /home/longvinter/entrypoint.sh "$@"
