#!/bin/sh
# Shared helpers for tools/gs.

# shellcheck shell=sh

GS_ROOT="${GS_ROOT:-}"
if [ -z "${GS_ROOT}" ]; then
  GS_ROOT="$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)"
fi

gs_die() {
  printf '%s\n' "$*" >&2
  exit 1
}

gs_log() {
  printf '%s\n' "$*"
}

gs_require_cmd() {
  command -v "$1" >/dev/null 2>&1 || gs_die "missing required command: $1"
}

gs_load_repo_meta() {
  # shellcheck disable=SC1090
  eval "$("${GS_ROOT}/ci/repo-meta.sh")"
  export IMAGE_OWNER
  export GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-${REPO}}"
}

gs_timestamp() {
  date '+%Y%m%d-%H%M%S'
}

gs_compose_dir() {
  dirname "$1"
}
