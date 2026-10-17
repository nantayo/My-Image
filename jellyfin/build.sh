#!/bin/sh
set -e
cd "$(dirname "$0")"

UPSTREAM="${1:-latest}"
if [ "$UPSTREAM" = "latest" ]; then
  UPSTREAM=$(curl -sf "https://hub.docker.com/v2/repositories/nyanmisaka/jellyfin/tags?page_size=100" \
    | grep -o '"name":"[^"]*"' | cut -d'"' -f4 \
    | grep -E '^[0-9]{6}-amd64' | sort -r | head -1)
fi

VERSION=$(echo "$UPSTREAM" | cut -d- -f1)

podman pull --quiet "docker.io/nyanmisaka/jellyfin:${UPSTREAM}"

BUILD_ARGS="--build-arg UPSTREAM_TAG=${UPSTREAM} --build-arg UPSTREAM_VERSION=${VERSION}"

podman build --quiet $BUILD_ARGS -t "localhost/jellyfin:${VERSION}" -f Containerfile .
podman tag "localhost/jellyfin:${VERSION}" localhost/jellyfin:latest