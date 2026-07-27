#!/bin/sh
# Offline tests for tools/gs and the server catalog.

set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "${ROOT}"

fail=0
export GS_TEST_MODE=1
export GS_DRY_RUN=1

echo "==> tools/gs list matches catalog"
list_ids="$(./tools/gs list | awk -F '\t' 'NR>1 {print $1}' | sort)"
catalog_ids="$(./ci/server-catalog.sh | awk -F '\t' '{print $1}' | sort)"
if [ "${list_ids}" != "${catalog_ids}" ]; then
  echo "gs list ids diverge from catalog" >&2
  printf 'list:\n%s\n' "${list_ids}" >&2
  printf 'catalog:\n%s\n' "${catalog_ids}" >&2
  fail=1
fi

echo "==> backup/restore tar round-trip"
fixture="$(mktemp -d)"
backup_dir="$(mktemp -d)"
# Use factorio compose dir layout under a temp overlay via GS_ROOT trick:
# Create a mini tree that mirrors factorio volumes under ROOT is heavy.
# Instead exercise gs_tar_backup helpers through a disposable game dir under tmp
# by invoking tar helpers with a fake compose relative to a copied stub.

stub_root="$(mktemp -d)"
mkdir -p "${stub_root}/ci" "${stub_root}/tools" "${stub_root}/fake-game/data"
cp "${ROOT}/ci/repo-meta.sh" "${stub_root}/ci/repo-meta.sh"
cat >"${stub_root}/ci/server-catalog.sh" <<'EOF'
#!/bin/sh
set -eu
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
  "fake" "fake-game/docker-compose.yml" "fake" "data" "FAKE_FORCE_UPDATE" "process" "1"
EOF
chmod +x "${stub_root}/ci/server-catalog.sh" "${stub_root}/ci/repo-meta.sh"
printf 'hello\n' >"${stub_root}/fake-game/data/world.txt"
cp -a "${ROOT}/tools/." "${stub_root}/tools/"

GS_ROOT="${stub_root}" GS_TEST_MODE=1 GS_BACKUP_DIR="${backup_dir}" \
  GITHUB_REPOSITORY="example/dockerized-game-servers" \
  "${stub_root}/tools/gs" backup fake >/dev/null

archive="$(find "${backup_dir}/fake" -type f -name '*.tar.gz' | head -n 1)"
if [ -z "${archive}" ]; then
  echo "backup did not create archive" >&2
  fail=1
else
  rm -f "${stub_root}/fake-game/data/world.txt"
  GS_ROOT="${stub_root}" GS_TEST_MODE=1 \
    GITHUB_REPOSITORY="example/dockerized-game-servers" \
    "${stub_root}/tools/gs" restore fake "${archive}" >/dev/null
  if [ ! -f "${stub_root}/fake-game/data/world.txt" ]; then
    echo "restore did not recreate world.txt" >&2
    fail=1
  fi
fi

echo "==> update dry-run prints force env"
update_out="$(GS_ROOT="${stub_root}" GS_TEST_MODE=1 GS_DRY_RUN=1 \
  GITHUB_REPOSITORY="example/dockerized-game-servers" \
  "${stub_root}/tools/gs" update fake 2>&1 || true)"
printf '%s\n' "${update_out}" | grep -q 'FAKE_FORCE_UPDATE=true' || {
  echo "update dry-run missing force env" >&2
  printf '%s\n' "${update_out}" >&2
  fail=1
}

rm -rf "${fixture}" "${backup_dir}" "${stub_root}"

if [ "${fail}" -ne 0 ]; then
  echo "test-tools failed" >&2
  exit 1
fi

echo "test-tools ok"
