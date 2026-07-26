#!/bin/sh
# Lightweight repository checks for CI.

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "${ROOT}"

fail=0

echo "==> Checking required paths"
./ci/image-matrix.sh | while IFS="$(printf '\t')" read -r name context dockerfile base; do
  [ -n "${name}" ] || continue
  if [ ! -d "${context}" ]; then
    echo "missing context: ${context} (${name})" >&2
    exit 1
  fi
  if [ ! -f "${dockerfile}" ]; then
    echo "missing dockerfile: ${dockerfile} (${name})" >&2
    exit 1
  fi
done || fail=1

echo "==> Checking compose files"
for compose in \
  minecraft/fabric/docker-compose.yml \
  minecraft/vanilla/docker-compose.yml \
  minecraft/forge/docker-compose.yml \
  valheim/vanilla/docker-compose.yml \
  valheim/plus/docker-compose.yml \
  ground-branch/docker-compose.yml \
  core-keeper/docker-compose.yml \
  arma/arma-3/docker-compose.yml \
  hytale/docker-compose.yml
do
  if [ ! -f "${compose}" ]; then
    echo "missing compose: ${compose}" >&2
    fail=1
    continue
  fi
  if command -v docker >/dev/null 2>&1; then
    if ! docker compose -f "${compose}" config >/dev/null; then
      echo "compose invalid: ${compose}" >&2
      fail=1
    fi
  fi
done

echo "==> Checking for Nomad leftovers"
if [ -n "$(find . -name '*.nomad' -print -quit 2>/dev/null)" ]; then
  echo "nomad files still present" >&2
  fail=1
fi

echo "==> Shell script syntax"
tmp="$(mktemp)"
find ci bases minecraft valheim ground-branch core-keeper arma -type f \( \
  -name '*.sh' -o -name 'entrypoint.sh' -o -name 'docker-entrypoint.sh' -o -name 'runtime.sh' \
\) >"${tmp}" 2>/dev/null || true
while IFS= read -r script; do
  [ -f "${script}" ] || continue
  shebang="$(head -n 1 "${script}" 2>/dev/null || true)"
  case "${shebang}" in
    *bash*)
      if ! bash -n "${script}"; then
        echo "syntax error: ${script}" >&2
        fail=1
      fi
      ;;
    *)
      if ! sh -n "${script}"; then
        echo "syntax error: ${script}" >&2
        fail=1
      fi
      ;;
  esac
done <"${tmp}"
rm -f "${tmp}"

echo "==> Python syntax"
if ! python3 -m py_compile ci/resolve-minecraft-build.py; then
  echo "python syntax error: ci/resolve-minecraft-build.py" >&2
  fail=1
fi

if [ "${fail}" -ne 0 ]; then
  echo "ci-check failed" >&2
  exit 1
fi

echo "ci-check ok"
