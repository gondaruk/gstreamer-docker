#!/usr/bin/env bash

set -euox pipefail

GSTREAMER_REPO="${GSTREAMER_REPO:-"https://gitlab.freedesktop.org/gstreamer/gstreamer.git"}"
GSTREAMER_BRANCH="${GSTREAMER_BRANCH:="1.20"}"

PLATFORM="${PLATFORM:-"linux/amd64,linux/arm64"}"
DOCKER_PUSH="${DOCKER_PUSH:-"true"}"
DOCKER_USE_CACHE="${DOCKER_USE_CACHE:-"false"}"
DOCKER_REGISTRY="${DOCKER_REGISTRY:-"gondaruk/gstreamer"}"

BUILD_ARGS=(
  --build-arg APP_NAME='gstreamer'
  --build-arg APP_DESC='GStreamer minimal build suitable for ci'
  --build-arg VERSION="$GSTREAMER_BRANCH"
  --build-arg VCS_URL="$GSTREAMER_REPO"
  --build-arg VCS_REF="$(git -C ./gstreamer rev-parse --verify HEAD)"
  --build-arg VCS_BRANCH="$GSTREAMER_BRANCH"
  --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
)

build() {
  local BASE="$1"
  local TAG="$DOCKER_REGISTRY:$GSTREAMER_BRANCH-$BASE"
  local DOCKERFILE="docker/$BASE/Dockerfile"

  if [ -n "$PLATFORM" ]; then
    ARGS=()
    if [[ "$DOCKER_PUSH" == "true" ]]; then
      ARGS+=(--push)
    fi
    if [[ "$DOCKER_USE_CACHE" == "false" ]]; then
      ARGS+=(--no-cache)
    fi

    docker buildx build \
      --platform="$PLATFORM" \
      --tag "$TAG" \
      "${BUILD_ARGS[@]}" \
      . \
      -f "$DOCKERFILE" \
      "${ARGS[@]}"

  else
    ARGS=()
    if [[ "$DOCKER_USE_CACHE" == "false" ]]; then
      ARGS+=(--no-cache)
    fi

    docker build \
      --tag "$TAG" \
      "${BUILD_ARGS[@]}" \
      . \
      -f "$DOCKERFILE" \
      "${ARGS[@]}"

    if [[ "$DOCKER_PUSH" == "true" ]]; then
      docker push "$TAG"
    fi
  fi
}

fetch() {
  local REPO="$1"
  local BRANCH="$2"
  local DIR="./gstreamer"

  [ -d "$DIR" ] || git clone -b "${BRANCH}" --depth 1 "${REPO}" "${DIR}"
}

#
# Build
#
main() {
  echo "Fetching $GSTREAMER_BRANCH sources from $GSTREAMER_REPO"

  fetch "$GSTREAMER_REPO" "$GSTREAMER_BRANCH"

  echo "Building $DOCKER_REGISTRY:* Docker images"
  build debian-bullseye-slim
  build ubuntu-20.04
}

main
