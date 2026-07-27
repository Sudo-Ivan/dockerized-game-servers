#!/bin/bash
set -eu

# shellcheck source=/usr/local/bin/linuxgsm-tar-install.sh
. /usr/local/bin/linuxgsm-tar-install.sh

BFV_EXTRA_ARGS="${BFV_EXTRA_ARGS:-}"
lgsm_volume_seed "${BFV_DIR}" "${BFV_SEED_DIR}" "start.sh"
cd "${BFV_DIR}"
chmod +x ./start.sh
echo "--- Starting bfv dedicated server ---"
# shellcheck disable=SC2086
exec ./start.sh +statusMonitor 1 ${BFV_EXTRA_ARGS}
