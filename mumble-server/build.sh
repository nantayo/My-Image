#!/bin/sh
# mumble-server 构建脚本：./build.sh [VERSION] [ALPINE_VERSION]
# 详见 总结.md §4.6
set -e
cd "$(dirname "$0")"

VERSION="${1:-latest}"
if [ "$VERSION" = latest ]; then
  TAG=$(curl -sf "https://api.github.com/repos/mumble-voip/mumble/releases/latest" | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')
  VERSION=${TAG#v}
fi
ALPINE_VERSION="${2:-3.24}"

TARBALL="mumble-${VERSION}.tar.gz"
curl -fsSL -o "$TARBALL" "https://github.com/mumble-voip/mumble/releases/download/v${VERSION}/${TARBALL}"

podman build --quiet --build-arg MUMBLE_VERSION="$VERSION" --build-arg ALPINE_VERSION="$ALPINE_VERSION" -t "localhost/mumble-server:${VERSION}" -f Containerfile .

rm -f "$TARBALL"
