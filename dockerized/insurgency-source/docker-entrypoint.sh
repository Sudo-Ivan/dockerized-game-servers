#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${INS_SOURCE_DIR}"
    chown -R inssource:inssource "${INS_SOURCE_DIR}" 2>/dev/null || true
    exec runuser -u inssource -- /bin/bash /home/inssource/entrypoint.sh "$@"
fi

exec /bin/bash /home/inssource/entrypoint.sh "$@"
