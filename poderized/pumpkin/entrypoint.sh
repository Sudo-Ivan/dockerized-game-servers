#!/bin/bash
set -eu

PUMPKIN_DIR="${PUMPKIN_DIR:-/data}"
PUMPKIN_IP="${PUMPKIN_IP:-0.0.0.0}"
PUMPKIN_PORT="${PUMPKIN_PORT:-25565}"
PUMPKIN_BEDROCK="${PUMPKIN_BEDROCK:-true}"
PUMPKIN_BEDROCK_PORT="${PUMPKIN_BEDROCK_PORT:-19132}"
PUMPKIN_MOTD="${PUMPKIN_MOTD:-A blazingly fast Pumpkin server!}"
PUMPKIN_MAX_PLAYERS="${PUMPKIN_MAX_PLAYERS:-1000}"
PUMPKIN_ONLINE_MODE="${PUMPKIN_ONLINE_MODE:-true}"
PUMPKIN_SEED="${PUMPKIN_SEED:-}"
PUMPKIN_GAMEMODE="${PUMPKIN_GAMEMODE:-Survival}"
PUMPKIN_DIFFICULTY="${PUMPKIN_DIFFICULTY:-Normal}"
PUMPKIN_EXTRA_ARGS="${PUMPKIN_EXTRA_ARGS:-}"

cfg="${PUMPKIN_DIR}/pumpkin.toml"
if [ ! -f "${cfg}" ]; then
    mkdir -p "${PUMPKIN_DIR}"
    {
        if [ -n "${PUMPKIN_SEED}" ]; then
            printf 'seed = "%s"\n' "${PUMPKIN_SEED}"
        fi
        printf 'default_gamemode = "%s"\n' "${PUMPKIN_GAMEMODE}"
        printf 'default_difficulty = "%s"\n' "${PUMPKIN_DIFFICULTY}"
        cat <<EOF

[networking.java]
address = "${PUMPKIN_IP}:${PUMPKIN_PORT}"
motd = "${PUMPKIN_MOTD}"
max_players = ${PUMPKIN_MAX_PLAYERS}
online_mode = ${PUMPKIN_ONLINE_MODE}

[networking.bedrock]
enabled = ${PUMPKIN_BEDROCK}
motd = "${PUMPKIN_MOTD}"
max_players = ${PUMPKIN_MAX_PLAYERS}
online_mode = ${PUMPKIN_ONLINE_MODE}

[networking.bedrock.nethernet]
address = "${PUMPKIN_IP}:${PUMPKIN_BEDROCK_PORT}"
EOF
    } >"${cfg}"
fi

cd "${PUMPKIN_DIR}"
echo "--- Starting Pumpkin on ${PUMPKIN_IP}:${PUMPKIN_PORT} ---"
# shellcheck disable=SC2086
exec /opt/pumpkin/pumpkin ${PUMPKIN_EXTRA_ARGS}
