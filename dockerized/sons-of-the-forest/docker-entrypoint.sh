#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${SOTF_DIR}"
    chown -R sotf:sotf "${SOTF_DIR}" 2>/dev/null || true
    exec runuser -u sotf -- /bin/bash /home/sotf/entrypoint.sh "$@"
fi

exec /bin/bash /home/sotf/entrypoint.sh "$@"
