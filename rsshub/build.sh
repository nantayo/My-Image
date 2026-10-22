#!/bin/sh
set -e
cd "$(dirname "$0")"

UPSTREAM="${1:-latest}"

if [ "$UPSTREAM" = "latest" ]; then
  UPSTREAM=$(curl -sf "https://hub.docker.com/v2/repositories/diygod/rsshub/tags?page_size=100" | grep -o '"name":"[^"]*"' | cut -d'"' -f4 | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' | sort -r | head -1)
fi

VERSION=$(echo "$UPSTREAM" | tr -d '-')

podman pull --quiet "docker.io/diygod/rsshub:${UPSTREAM}"

BUILD_ARGS="--build-arg UPSTREAM_TAG=${UPSTREAM}"

podman build --quiet $BUILD_ARGS -t "localhost/rsshub:${VERSION}" -f Containerfile .
podman tag "localhost/rsshub:${VERSION}" localhost/rsshub:latest
