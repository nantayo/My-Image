#!/bin/sh
set -e
cd "$(dirname "$0")"

VERSION="${1:-latest}"
if [ "$VERSION" = "latest" ]; then
  VERSION=$(curl -sf "https://api.github.com/repos/mumble-voip/mumble/releases/latest" \
    | grep -m1 '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')
fi

ALPINE_VERSION="${2:-3.24}"

TARBALL="mumble-${VERSION}.tar.gz"
curl -fsSL -o "$TARBALL" "https://github.com/mumble-voip/mumble/releases/download/v${VERSION}/${TARBALL}"

BUILD_ARGS="--build-arg MUMBLE_VERSION=$VERSION --build-arg ALPINE_VERSION=$ALPINE_VERSION"

podman build --quiet $BUILD_ARGS -t "localhost/mumble-server:$VERSION" -f Containerfile .

rm -f "$TARBALL"