#!/bin/bash
set -eu

if [ "$(id -u)" = "0" ]; then
    mkdir -p "${INS_SANDSTORM_DIR}"
    chown -R inssandstorm:inssandstorm "${INS_SANDSTORM_DIR}" 2>/dev/null || true
    exec runuser -u inssandstorm -- /bin/bash /home/inssandstorm/entrypoint.sh "$@"
fi

exec /bin/bash /home/inssandstorm/entrypoint.sh "$@"
