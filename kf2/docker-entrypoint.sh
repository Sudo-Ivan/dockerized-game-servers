#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${KF2_DIR}"
    chown -R kf2:kf2 "${KF2_DIR}" 2>/dev/null || true
    exec runuser -u kf2 -- /bin/bash /home/kf2/entrypoint.sh "$@"
fi

exec /bin/bash /home/kf2/entrypoint.sh "$@"
