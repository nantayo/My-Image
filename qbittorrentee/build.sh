#!/bin/sh
set -e
cd "$(dirname "$0")"

VERSION="${1:-latest}"
if [ "$VERSION" = "latest" ]; then
  VERSION=$(curl -sf "https://api.github.com/repos/c0re100/qBittorrent-Enhanced-Edition/releases/latest" | grep -m1 '"tag_name"' | cut -d'"' -f4 | sed 's/^release-//')
fi

ALPINE_VERSION="${2:-3.24}"

BUILD_ARGS="--build-arg QBT_VERSION=$VERSION --build-arg ALPINE_VERSION=$ALPINE_VERSION"

podman build --quiet $BUILD_ARGS -t "localhost/qbittorrentee:$VERSION" -f Containerfile .
