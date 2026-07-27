#!/bin/sh
# Lightweight repository checks for CI.

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "${ROOT}"

fail=0

chmod +x ci/*.sh
# shellcheck disable=SC1090
eval "$(./ci/repo-meta.sh)"
export IMAGE_OWNER
export GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-${REPO}}"

echo "==> Repository identity"
echo "  repo=${REPO}"
echo "  image_owner=${IMAGE_OWNER}"
echo "  docs_url=${DOCS_URL}"

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
  factorio/docker-compose.yml \
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

echo "==> Checking for hardcoded image owners in compose"
compose_hits="$(git ls-files '*docker-compose.yml' | while IFS= read -r compose; do
  case "${compose}" in
    hytale/*) continue ;;
  esac
  if grep -n -E 'ghcr\.io/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/' "${compose}"; then
    printf '%s\n' "${compose}"
  fi
done || true)"
if [ -n "${compose_hits}" ]; then
  echo "compose files must use ghcr.io/\${IMAGE_OWNER}/... not a fixed owner" >&2
  printf '%s\n' "${compose_hits}" >&2
  fail=1
fi

echo "==> Checking for Nomad leftovers"
if [ -n "$(find . -name '*.nomad' -print -quit 2>/dev/null)" ]; then
  echo "nomad files still present" >&2
  fail=1
fi

echo "==> Shell script syntax"
tmp="$(mktemp)"
find ci bases minecraft valheim ground-branch core-keeper factorio arma -type f \( \
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

echo "==> Docs package manager"
if [ ! -f docs/pnpm-lock.yaml ]; then
  echo "missing docs/pnpm-lock.yaml" >&2
  fail=1
fi
if [ -f docs/package-lock.json ]; then
  echo "docs/package-lock.json must not exist when using pnpm" >&2
  fail=1
fi
if ! grep -q 'pnpm@11\.' docs/package.json; then
  echo "docs/package.json must pin pnpm 11+" >&2
  fail=1
fi

if [ "${fail}" -ne 0 ]; then
  echo "ci-check failed" >&2
  exit 1
fi

echo "ci-check ok"
