#!/bin/sh
# Match changed paths against CI path categories.
# Usage: changed-paths.sh <category> <base_ref> <head_ref>
#
# Categories:
#   workflow   files that should trigger the ci workflow
#   docker-verify files that should trigger PR base image builds

set -eu

category="${1:?category required}"
base_ref="${2:?base ref required}"
head_ref="${3:?head ref required}"

match_workflow() {
  file="$1"
  case "${file}" in
    .github/workflows/ci.yml|.github/workflows/docker-image.yml) return 0 ;;
    ci/*) return 0 ;;
    tools/*) return 0 ;;
    dockerized/*) return 0 ;;
    */docker-compose.yml) return 0 ;;
    */Dockerfile) return 0 ;;
    */compose.yml) return 0 ;;
  esac
  case "${file}" in
    *.sh) return 0 ;;
  esac
  return 1
}

match_docker_verify() {
  file="$1"
  case "${file}" in
    .github/workflows/docker-image.yml|.github/workflows/ci.yml) return 0 ;;
    dockerized/*) return 0 ;;
    ci/build-image.sh|ci/build-one-image.sh|ci/image-matrix.sh|ci/github-matrix.py) return 0 ;;
  esac
  return 1
}

match_file() {
  case "${category}" in
    workflow) match_workflow "$1" ;;
    docker-verify) match_docker_verify "$1" ;;
    *) echo "unknown category: ${category}" >&2; exit 2 ;;
  esac
}

if ! git rev-parse --verify "${base_ref}" >/dev/null 2>&1; then
  echo "changed-paths: base ref not found: ${base_ref}" >&2
  exit 1
fi
if ! git rev-parse --verify "${head_ref}" >/dev/null 2>&1; then
  echo "changed-paths: head ref not found: ${head_ref}" >&2
  exit 1
fi

matched=0
diff_tmp="$(mktemp)"
git diff --name-only "${base_ref}" "${head_ref}" >"${diff_tmp}"
while IFS= read -r file; do
  [ -n "${file}" ] || continue
  if match_file "${file}"; then
    matched=1
    break
  fi
done <"${diff_tmp}"
rm -f "${diff_tmp}"

if [ "${matched}" -eq 1 ]; then
  exit 0
fi
exit 1
