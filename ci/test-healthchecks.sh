#!/bin/sh
# Healthcheck presence and offline probe tests.

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "${ROOT}"

fail=0

echo "==> HEALTHCHECK presence for first-party servers"
./ci/server-catalog.sh | while IFS="$(printf '\t')" read -r id compose _container _volumes _update_envs _health first_party; do
  [ -n "${id}" ] || continue
  [ "${first_party}" = "1" ] || continue

  compose_dir="$(dirname "${compose}")"
  health_script="${compose_dir}/healthcheck.sh"
  dockerfile="${compose_dir}/Dockerfile"

  if [ ! -f "${health_script}" ]; then
    echo "missing healthcheck.sh for ${id}: ${health_script}" >&2
    exit 1
  fi
  if [ ! -f "${dockerfile}" ]; then
    echo "missing Dockerfile for ${id}: ${dockerfile}" >&2
    exit 1
  fi
  if ! grep -q 'HEALTHCHECK' "${dockerfile}"; then
    echo "missing HEALTHCHECK in ${dockerfile}" >&2
    exit 1
  fi
  if ! grep -q 'healthcheck:' "${compose}"; then
    echo "missing compose healthcheck for ${id}: ${compose}" >&2
    exit 1
  fi
done || fail=1

echo "==> Core Keeper healthcheck logic"
ck_tmp="$(mktemp -d)"
export CK_INSTALL_DIR="${ck_tmp}"
export CK_HEALTH_SKIP_PROCESS=1
if sh "${ROOT}/core-keeper/healthcheck.sh"; then
  echo "expected fail without GameID.txt" >&2
  fail=1
fi
printf 'TestGameID12345\n' >"${ck_tmp}/GameID.txt"
if ! sh "${ROOT}/core-keeper/healthcheck.sh"; then
  echo "expected pass with GameID.txt" >&2
  fail=1
fi
rm -rf "${ck_tmp}"

echo "==> Core Keeper ready helpers"
ready_out="$(mktemp)"
bash -c '
  set -e
  # shellcheck disable=SC1091
  . "$1/core-keeper/ready.sh"
  ck_print_game_id "ABC123XYZ"
  ck_print_ready_status
' bash "${ROOT}" >"${ready_out}"
plain="$(tr -d '\033' <"${ready_out}" | sed 's/\[[0-9;]*m//g')"
printf '%s\n' "${plain}" | grep -q 'Game ID: ABC123XYZ' || {
  echo "ready helper missing Game ID line" >&2
  fail=1
}
printf '%s\n' "${plain}" | grep -q 'Status: server ready and ready for players!' || {
  echo "ready helper missing status line" >&2
  fail=1
}
rm -f "${ready_out}"

echo "==> Minecraft TCP healthcheck against closed port"
export SERVER_PORT=1
if sh "${ROOT}/minecraft/fabric/healthcheck.sh"; then
  echo "expected fail for closed TCP port 1" >&2
  fail=1
fi

if [ "${fail}" -ne 0 ]; then
  echo "test-healthchecks failed" >&2
  exit 1
fi

echo "test-healthchecks ok"
