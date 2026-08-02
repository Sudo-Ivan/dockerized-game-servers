#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${CSS_DIR}"
    chown -R cssource:cssource "${CSS_DIR}" 2>/dev/null || true
    exec runuser -u cssource -- /bin/bash /home/cssource/entrypoint.sh "$@"
fi

exec /bin/bash /home/cssource/entrypoint.sh "$@"
