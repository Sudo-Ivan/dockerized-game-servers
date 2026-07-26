#!/bin/sh
# Build and optionally push a container image with buildx.
# Usage: build-image.sh <name> <context> <dockerfile> [base_image]

set -eu

NAME="${1:?name required}"
CONTEXT="${2:?context required}"
DOCKERFILE="${3:?dockerfile required}"
BASE_IMAGE="${4:-}"

REGISTRY="${REGISTRY:-ghcr.io}"
IMAGE_OWNER="${IMAGE_OWNER:-sudo-ivan/dockerized-game-servers}"
TAG="${TAG:-latest}"
PUSH="${PUSH:-false}"
PLATFORM="${PLATFORM:-linux/amd64}"

IMAGE="${REGISTRY}/${IMAGE_OWNER}/${NAME}:${TAG}"
SHA_TAG="${REGISTRY}/${IMAGE_OWNER}/${NAME}:sha-${GITHUB_SHA:-local}"

echo "Building ${IMAGE}"
echo "  context=${CONTEXT}"
echo "  dockerfile=${DOCKERFILE}"
echo "  platform=${PLATFORM}"
echo "  push=${PUSH}"

set -- \
  docker buildx build \
  --platform "${PLATFORM}" \
  --file "${DOCKERFILE}" \
  --tag "${IMAGE}" \
  --tag "${SHA_TAG}" \
  --label "org.opencontainers.image.source=https://github.com/Sudo-Ivan/dockerized-game-servers" \
  --label "org.opencontainers.image.revision=${GITHUB_SHA:-local}" \
  --cache-from "type=gha,scope=${NAME}" \
  --cache-to "type=gha,mode=max,scope=${NAME}"

if [ -n "${BASE_IMAGE}" ]; then
  set -- "$@" --build-arg "BASE_IMAGE=${BASE_IMAGE}"
  echo "  base=${BASE_IMAGE}"
fi

if [ "${PUSH}" = "true" ]; then
  set -- "$@" --push
else
  set -- "$@" --load
fi

set -- "$@" "${CONTEXT}"
"$@"

echo "Done: ${IMAGE}"
