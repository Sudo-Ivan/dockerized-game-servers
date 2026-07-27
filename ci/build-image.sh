#!/bin/sh
# Build and optionally push a container image with buildx.
# Usage: build-image.sh <name> <context> <dockerfile> [base_image]
#
# Optional env:
#   BUILD_ARGS_FILE  file with KEY=VALUE lines passed as --build-arg
#   EXTRA_TAGS       space-separated extra image tags (full refs or bare tags)
#   OCI_LICENSES     override license label (default ISC)
#
# PUSH=true uses buildx (GH cache + push). PUSH=false uses docker build so
# locally loaded bases are visible to later FROM stages.
#
# OCI provenance labels are owner-agnostic (resolved via repo-meta.sh).

set -eu

IMAGE_NAME="${1:?name required}"
CONTEXT="${2:?context required}"
DOCKERFILE="${3:?dockerfile required}"
BASE_IMAGE="${4:-}"

ROOT="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1090
eval "$("${ROOT}/ci/repo-meta.sh")"
# repo-meta exports NAME as the git repo name. Keep the image name separate.
NAME="${IMAGE_NAME}"

REGISTRY="${REGISTRY:-ghcr.io}"
TAG="${TAG:-latest}"
PUSH="${PUSH:-false}"
PLATFORM="${PLATFORM:-linux/amd64}"

IMAGE="${REGISTRY}/${IMAGE_OWNER}/${NAME}:${TAG}"
SHA_TAG="${REGISTRY}/${IMAGE_OWNER}/${NAME}:sha-${GITHUB_SHA:-local}"
OCI_REVISION="${GITHUB_SHA:-local}"
OCI_CREATED="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
OCI_LICENSES="${OCI_LICENSES:-ISC}"

echo "Building ${IMAGE}"
echo "  context=${CONTEXT}"
echo "  dockerfile=${DOCKERFILE}"
echo "  platform=${PLATFORM}"
echo "  push=${PUSH}"
echo "  source=${GITHUB_URL}"

if [ "${PUSH}" = "true" ]; then
  set -- \
    docker buildx build \
    --platform "${PLATFORM}" \
    --file "${DOCKERFILE}" \
    --tag "${IMAGE}" \
    --tag "${SHA_TAG}" \
    --label "org.opencontainers.image.source=${GITHUB_URL}" \
    --label "org.opencontainers.image.url=${GITHUB_URL}" \
    --label "org.opencontainers.image.revision=${OCI_REVISION}" \
    --label "org.opencontainers.image.created=${OCI_CREATED}" \
    --label "org.opencontainers.image.title=${NAME}" \
    --label "org.opencontainers.image.licenses=${OCI_LICENSES}" \
    --cache-from "type=gha,scope=${NAME}" \
    --cache-to "type=gha,mode=max,scope=${NAME}" \
    --push
else
  set -- \
    docker build \
    --platform "${PLATFORM}" \
    --file "${DOCKERFILE}" \
    --tag "${IMAGE}" \
    --tag "${SHA_TAG}" \
    --label "org.opencontainers.image.source=${GITHUB_URL}" \
    --label "org.opencontainers.image.url=${GITHUB_URL}" \
    --label "org.opencontainers.image.revision=${OCI_REVISION}" \
    --label "org.opencontainers.image.created=${OCI_CREATED}" \
    --label "org.opencontainers.image.title=${NAME}" \
    --label "org.opencontainers.image.licenses=${OCI_LICENSES}"
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
        echo "  tag ${extra}"
        ;;
      *)
        set -- "$@" --tag "${REGISTRY}/${IMAGE_OWNER}/${NAME}:${extra}"
        echo "  tag ${REGISTRY}/${IMAGE_OWNER}/${NAME}:${extra}"
        ;;
    esac
  done
fi

set -- "$@" "${CONTEXT}"
"$@"

if [ "${PUSH}" = "true" ]; then
  echo "Pulling ${IMAGE} for local verification and scan"
  docker pull "${IMAGE}"
fi

echo "Done: ${IMAGE}"
