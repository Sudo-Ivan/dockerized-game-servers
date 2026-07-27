#!/bin/sh
# Build one catalog image (and its base locally when PUSH=false).
# Usage: build-one-image.sh <image_name>
#
# Uses PUSH, TAG, REGISTRY, IMAGE_OWNER, PLATFORM from the environment.

set -eu

IMAGE_NAME="${1:?image name required}"

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
cd "${ROOT}"

# shellcheck disable=SC1090
eval "$("${ROOT}/ci/repo-meta.sh")"
export IMAGE_OWNER

REGISTRY="${REGISTRY:-ghcr.io}"
TAG="${TAG:-latest}"
PUSH="${PUSH:-false}"

context=""
dockerfile=""
base=""
found=0

matrix_tmp="$(mktemp)"
./ci/image-matrix.sh >"${matrix_tmp}"

while IFS="$(printf '\t')" read -r name ctx df b; do
  [ "${name}" = "${IMAGE_NAME}" ] || continue
  context="${ctx}"
  dockerfile="${df}"
  base="${b}"
  found=1
  break
done <"${matrix_tmp}"

if [ "${found}" -ne 1 ]; then
  rm -f "${matrix_tmp}"
  echo "image not in ci/image-matrix.sh: ${IMAGE_NAME}" >&2
  exit 1
fi

lookup_base_paths() {
  base_name="$1"
  base_context=""
  base_dockerfile=""
  base_found=0
  while IFS="$(printf '\t')" read -r name ctx df b; do
    [ "${name}" = "${base_name}" ] || continue
    [ -n "${b}" ] && continue
    base_context="${ctx}"
    base_dockerfile="${df}"
    base_found=1
    break
  done <"${matrix_tmp}"
  if [ "${base_found}" -ne 1 ]; then
    echo "base not in ci/image-matrix.sh: ${base_name}" >&2
    exit 1
  fi
}

if [ -n "${base}" ]; then
  if [ "${PUSH}" = "true" ]; then
    base_image="${REGISTRY}/${IMAGE_OWNER}/${base}:${TAG}"
  else
    lookup_base_paths "${base}"
    ./ci/build-image.sh "${base}" "${base_context}" "${base_dockerfile}"
    base_image="${REGISTRY}/${IMAGE_OWNER}/${base}:${TAG}"
  fi
  ./ci/build-image.sh "${IMAGE_NAME}" "${context}" "${dockerfile}" "${base_image}"
else
  ./ci/build-image.sh "${IMAGE_NAME}" "${context}" "${dockerfile}"
fi

rm -f "${matrix_tmp}"
