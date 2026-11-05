#!/bin/sh
set -e
cd "$(dirname "$0")"

VERSION="${1:-latest}"
if [ "$VERSION" = "latest" ]; then
  VERSION=$(curl -sf "https://api.github.com/repos/PBH-BTN/PeerBanHelper/releases/latest" | grep -m1 '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')
fi

ALPINE_VERSION="${2:-3.24}"

BUILD_ARGS="--build-arg PBH_VERSION=$VERSION --build-arg ALPINE_VERSION=$ALPINE_VERSION"

podman build --quiet $BUILD_ARGS -t "localhost/peerbanhelper:$VERSION" -f Containerfile .
