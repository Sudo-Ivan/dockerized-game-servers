#!/bin/bash
set -eu

# shellcheck source=/usr/local/bin/linuxgsm-tar-install.sh
. /usr/local/bin/linuxgsm-tar-install.sh

BF1942_EXTRA_ARGS="${BF1942_EXTRA_ARGS:-}"
lgsm_volume_seed "${BF1942_DIR}" "${BF1942_SEED_DIR}" "start.sh"
cd "${BF1942_DIR}"
chmod +x ./start.sh
echo "--- Starting bf1942 dedicated server ---"
# shellcheck disable=SC2086
exec ./start.sh +hostServer 1 +dedicated 1 ${BF1942_EXTRA_ARGS}
