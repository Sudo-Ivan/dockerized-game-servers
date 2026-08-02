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
./ci/image-matrix.sh | while IFS="$(printf '\t')" read -r name context dockerfile _base; do
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
./ci/server-catalog.sh | while IFS="$(printf '\t')" read -r id compose _container _volumes _update_envs _health _first_party; do
  [ -n "${id}" ] || continue
  if [ ! -f "${compose}" ]; then
    echo "missing compose: ${compose} (${id})" >&2
    exit 1
  fi
  if command -v docker >/dev/null 2>&1; then
    if ! docker compose -f "${compose}" config >/dev/null; then
      echo "compose invalid: ${compose} (${id})" >&2
      exit 1
    fi
  fi
done || fail=1

echo "==> Minecraft default versions"
chmod +x ci/check-minecraft-defaults.sh
./ci/check-minecraft-defaults.sh || fail=1

echo "==> Minecraft scaffold compose"
if command -v docker >/dev/null 2>&1; then
  for scaffold in \
    dockerized/minecraft/fabric/docker-compose.scaffold.yml \
    dockerized/minecraft/vanilla/docker-compose.scaffold.yml \
    dockerized/minecraft/forge/docker-compose.scaffold.yml \
    dockerized/minecraft/neoforge/docker-compose.scaffold.yml
  do
    if ! docker compose -f "${scaffold}" --env-file dockerized/minecraft/defaults.env config >/dev/null; then
      echo "compose invalid: ${scaffold}" >&2
      fail=1
    fi
  done
fi

echo "==> Checking for hardcoded image owners in compose"
hardcoded=0
./ci/server-catalog.sh | while IFS="$(printf '\t')" read -r id compose _container _volumes _update_envs _health first_party; do
  [ -n "${id}" ] || continue
  [ "${first_party}" = "1" ] || continue
  [ -f "${compose}" ] || continue
  if grep -n -E 'ghcr\.io/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/' "${compose}" >/dev/null 2>&1; then
    echo "compose files must use ghcr.io/\${IMAGE_OWNER}/... not a fixed owner" >&2
    grep -n -E 'ghcr\.io/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/' "${compose}" >&2 || true
    exit 1
  fi
done || hardcoded=1
if [ "${hardcoded}" -ne 0 ]; then
  fail=1
fi

echo "==> Checking for Nomad leftovers"
if [ -n "$(find . \( -path './docs/node_modules' -o -path '*/data/*' \) -prune -o -name '*.nomad' -print -quit 2>/dev/null)" ]; then
  echo "nomad files still present" >&2
  fail=1
fi

echo "==> Shell script syntax"
tmp="$(mktemp)"
roots_tmp="$(mktemp)"
./ci/script-roots.sh | sort -u >"${roots_tmp}"
while IFS= read -r root; do
  [ -n "${root}" ] || continue
  [ -d "${root}" ] || continue
  find "${root}" \( -path '*/data/*' -o -path '*/node_modules/*' \) -prune -o -type f \( \
    -name '*.sh' -o -name 'entrypoint.sh' -o -name 'docker-entrypoint.sh' -o -name 'runtime.sh' \
  \) -print >>"${tmp}" 2>/dev/null || true
done <"${roots_tmp}"
rm -f "${roots_tmp}"

sort -u "${tmp}" -o "${tmp}"
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
if ! python3 -m py_compile ci/github-matrix.py; then
  echo "python syntax error: ci/github-matrix.py" >&2
  fail=1
fi
if ! python3 -m py_compile dockerized/arma/arma-3/modlist.py dockerized/arma/arma-3/test_modlist.py; then
  echo "python syntax error: arma-3 modlist tests" >&2
  fail=1
fi
if ! python3 dockerized/arma/arma-3/test_modlist.py; then
  fail=1
fi
if ! sh -n ci/changed-paths.sh; then
  echo "shell syntax error: ci/changed-paths.sh" >&2
  fail=1
fi

echo "==> GitHub Actions image matrix"
if ! python3 ci/github-matrix.py bases | python3 -c "import json,sys; json.load(sys.stdin)"; then
  echo "invalid bases matrix json" >&2
  fail=1
fi
if ! python3 ci/github-matrix.py images | python3 -c "import json,sys; json.load(sys.stdin)"; then
  echo "invalid images matrix json" >&2
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

echo "==> Docs build and link checks"
chmod +x ci/test-docs.sh
if ! ./ci/test-docs.sh; then
  fail=1
fi

echo "==> ShellCheck"
if ! ./ci/shellcheck.sh; then
  fail=1
fi

echo "==> Healthcheck tests"
if ! ./ci/test-healthchecks.sh; then
  fail=1
fi

echo "==> Tools tests"
if ! ./ci/test-tools.sh; then
  fail=1
fi

if [ "${fail}" -ne 0 ]; then
  echo "ci-check failed" >&2
  exit 1
fi

echo "ci-check ok"
