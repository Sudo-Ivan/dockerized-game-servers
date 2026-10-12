#!/bin/sh
# Build and optionally push a container image with podman.
# Usage: build-image.sh <name> <context> <containerfile> [base_image]
#
# Optional env:
#   BUILD_ARGS_FILE  file with KEY=VALUE lines passed as --build-arg
#   EXTRA_TAGS       space-separated extra image tags (full refs or bare tags)
#   OCI_LICENSES     override license label (default ISC)
#   PODMAN_PULL      podman build --pull policy (default missing)
#
# PUSH=true pushes every tag with podman push after the build. PUSH=false
# builds locally only so locally loaded bases are visible to later FROM stages.
#
# OCI provenance labels are owner-agnostic (resolved via repo-meta.sh).

set -eu

IMAGE_NAME="${1:?name required}"
CONTEXT="${2:?context required}"
CONTAINERFILE="${3:?containerfile required}"
BASE_IMAGE="${4:-}"

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1090
eval "$("${ROOT}/ci/repo-meta.sh")"
# repo-meta exports NAME as the git repo name. Keep the image name separate.
NAME="${IMAGE_NAME}"

REGISTRY="${REGISTRY:-ghcr.io}"
TAG="${TAG:-latest}"
PUSH="${PUSH:-false}"
PLATFORM="${PLATFORM:-}"

IMAGE="${REGISTRY}/${IMAGE_OWNER}/${NAME}:${TAG}"
SHA_TAG="${REGISTRY}/${IMAGE_OWNER}/${NAME}:sha-${GITHUB_SHA:-local}"
OCI_REVISION="${GITHUB_SHA:-local}"
OCI_CREATED="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
OCI_LICENSES="${OCI_LICENSES:-ISC}"

echo "Building ${IMAGE}"
echo "  context=${CONTEXT}"
echo "  containerfile=${CONTAINERFILE}"
echo "  platform=${PLATFORM:-native}"
echo "  push=${PUSH}"
echo "  source=${GITHUB_URL}"

TAGS="${IMAGE} ${SHA_TAG}"

set -- \
  podman build \
  "--pull=${PODMAN_PULL:-missing}" \
  --format docker \
  --file "${CONTAINERFILE}" \
  --tag "${IMAGE}" \
  --tag "${SHA_TAG}" \
  --label "org.opencontainers.image.source=${GITHUB_URL}" \
  --label "org.opencontainers.image.url=${GITHUB_URL}" \
  --label "org.opencontainers.image.revision=${OCI_REVISION}" \
  --label "org.opencontainers.image.created=${OCI_CREATED}" \
  --label "org.opencontainers.image.title=${NAME}" \
  --label "org.opencontainers.image.licenses=${OCI_LICENSES}"

# An explicit --platform makes podman treat local base images as suspect and
# re-pull them. Only pass it for non-native cross builds.
if [ -n "${PLATFORM}" ]; then
  set -- "$@" --platform "${PLATFORM}"
fi

if [ -n "${BASE_IMAGE}" ]; then
  BASE_IMAGE="$(printf '%s' "${BASE_IMAGE}" | tr '[:upper:]' '[:lower:]')"
  set -- "$@" --build-arg "BASE_IMAGE=${BASE_IMAGE}"
  echo "  base=${BASE_IMAGE}"
fi

if [ -n "${BUILD_ARGS_FILE:-}" ]; then
  if [ ! -f "${BUILD_ARGS_FILE}" ]; then
    echo "BUILD_ARGS_FILE not found: ${BUILD_ARGS_FILE}" >&2
    exit 1
  fi
  while IFS= read -r line || [ -n "${line}" ]; do
    case "${line}" in
      ""|\#*) continue ;;
    esac
    set -- "$@" --build-arg "${line}"
    echo "  build-arg ${line}"
  done <"${BUILD_ARGS_FILE}"
fi

if [ -n "${EXTRA_TAGS:-}" ]; then
  for extra in ${EXTRA_TAGS}; do
    case "${extra}" in
      */*:*|*:* )
        set -- "$@" --tag "${extra}"
        TAGS="${TAGS} ${extra}"
        echo "  tag ${extra}"
        ;;
      *)
        extra_ref="${REGISTRY}/${IMAGE_OWNER}/${NAME}:${extra}"
        set -- "$@" --tag "${extra_ref}"
        TAGS="${TAGS} ${extra_ref}"
        echo "  tag ${extra_ref}"
        ;;
    esac
  done
fi

set -- "$@" "${CONTEXT}"
"$@"

if [ "${PUSH}" = "true" ]; then
  for ref in ${TAGS}; do
    echo "Pushing ${ref}"
    podman push --retry 3 --retry-delay 5s "${ref}"
  done
  echo "Pulling ${IMAGE} for local verification and scan"
  podman pull "${IMAGE}"
fi

echo "Done: ${IMAGE}"
