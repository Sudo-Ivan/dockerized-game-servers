#!/bin/sh
# Smoke-run each first-party compose server, then stop and remove on success.
# Usage: ./ci/smoke-run-servers.sh
#
# Optional env:
#   SMOKE_TIMEOUT_SEC  max seconds to wait for healthy/running (default 240)
#   SMOKE_ONLY         comma-separated server ids to test (default all first-party)

set -eu

ROOT="$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)"
cd "${ROOT}"

# shellcheck disable=SC1090
eval "$("${ROOT}/ci/repo-meta.sh")"
export IMAGE_OWNER
export REGISTRY="${REGISTRY:-ghcr.io}"

SMOKE_TIMEOUT_SEC="${SMOKE_TIMEOUT_SEC:-240}"
SMOKE_ONLY="${SMOKE_ONLY:-}"
REPORT="/tmp/gs-smoke-report.txt"
: >"${REPORT}"

ok=0
fail=0

cleanup_one() {
  compose="$1"
  container="$2"
  docker compose -f "${compose}" down --remove-orphans >/dev/null 2>&1 || true
  docker rm -f "${container}" >/dev/null 2>&1 || true
}

in_smoke_only() {
  id="$1"
  [ -z "${SMOKE_ONLY}" ] && return 0
  case ",${SMOKE_ONLY}," in
    *",${id},"*) return 0 ;;
    *) return 1 ;;
  esac
}

wait_success() {
  compose="$1"
  container="$2"
  health="$3"
  started_at="$(date +%s)"
  deadline=$(( started_at + SMOKE_TIMEOUT_SEC ))

  while [ "$(date +%s)" -lt "${deadline}" ]; do
    status="$(docker inspect -f '{{.State.Status}}' "${container}" 2>/dev/null || echo missing)"
    if [ "${status}" = "exited" ] || [ "${status}" = "dead" ] || [ "${status}" = "missing" ]; then
      code="$(docker inspect -f '{{.State.ExitCode}}' "${container}" 2>/dev/null || echo 1)"
      echo "container stopped (status=${status} exit=${code})" >&2
      docker compose -f "${compose}" logs --tail 100 >&2 || true
      return 1
    fi

    health_status="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "${container}" 2>/dev/null || echo none)"
    case "${health_status}" in
      healthy)
        echo "healthy"
        return 0
        ;;
      unhealthy)
        echo "unhealthy" >&2
        docker compose -f "${compose}" logs --tail 100 >&2 || true
        return 1
        ;;
    esac

    case "${health}" in
      tcp)
        if docker logs "${container}" 2>&1 | grep -Eq 'Done \(|For help, type|You need to agree to the EULA|Server started'; then
          echo "log-ready"
          return 0
        fi
        ;;
      process|gameid)
        if docker logs "${container}" 2>&1 | grep -Eqi 'server ready|Status: server ready|Hosting world|Game Server version|Dedicated server running|Hosting at|Factorio.*Server|Listening on|SteamGameServer_Init|World generation finished|omohaaded|Anonymous Steam login cannot download|SERVER STARTED|7 Days to Die|Terraria Server|StartGame done|Gameserver Steam|VAC secure mode|Palworld|Starbound|Space Engineers'; then
          # Arma missing owned server is a clear expected failure path.
          if docker logs "${container}" 2>&1 | grep -q 'Anonymous Steam login cannot download'; then
            echo "arma-needs-steam-login" >&2
            return 1
          fi
          echo "log-ready"
          return 0
        fi
        elapsed=$(( $(date +%s) - started_at ))
        if [ "${elapsed}" -ge 60 ] && [ "${status}" = "running" ]; then
          echo "running"
          return 0
        fi
        ;;
    esac

    sleep 5
  done

  echo "timeout after ${SMOKE_TIMEOUT_SEC}s" >&2
  docker inspect -f 'status={{.State.Status}} health={{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' "${container}" >&2 || true
  docker compose -f "${compose}" logs --tail 100 >&2 || true
  return 1
}

echo "Smoke testing first-party servers (timeout=${SMOKE_TIMEOUT_SEC}s)"
echo "image_owner=${IMAGE_OWNER}"

tmp_catalog="$(mktemp)"
./ci/server-catalog.sh >"${tmp_catalog}"

while IFS= read -r line || [ -n "${line}" ]; do
  [ -n "${line}" ] || continue
  id="$(printf '%s\n' "${line}" | awk -F'\t' '{print $1}')"
  compose="$(printf '%s\n' "${line}" | awk -F'\t' '{print $2}')"
  container="$(printf '%s\n' "${line}" | awk -F'\t' '{print $3}')"
  health="$(printf '%s\n' "${line}" | awk -F'\t' '{print $6}')"
  first_party="$(printf '%s\n' "${line}" | awk -F'\t' '{print $7}')"

  [ -n "${id}" ] || continue
  [ "${first_party}" = "1" ] || continue
  in_smoke_only "${id}" || continue

  printf '\n======== %s ========\n' "${id}"
  cleanup_one "${compose}" "${container}"

  err="$(mktemp)"
  if ! docker compose -f "${compose}" up -d --pull never --no-build 2>"${err}"; then
    echo "FAIL ${id}: compose up failed" | tee -a "${REPORT}"
    cat "${err}" >&2 || true
    rm -f "${err}"
    fail=$((fail + 1))
    cleanup_one "${compose}" "${container}"
    continue
  fi
  rm -f "${err}"

  if wait_success "${compose}" "${container}" "${health}"; then
    echo "OK ${id}" | tee -a "${REPORT}"
    ok=$((ok + 1))
  else
    echo "FAIL ${id}" | tee -a "${REPORT}"
    fail=$((fail + 1))
  fi
  cleanup_one "${compose}" "${container}"
done <"${tmp_catalog}"
rm -f "${tmp_catalog}"

echo
echo "======== SUMMARY ========"
cat "${REPORT}"
echo "ok=${ok} fail=${fail}"
[ "${fail}" -eq 0 ]
