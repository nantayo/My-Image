#!/bin/sh
# peerbanhelper 构建脚本：./build.sh [VERSION] [ALPINE_VERSION]
# 详见 总结.md §4.3
set -e
cd "$(dirname "$0")"

VERSION="${1:-latest}"
if [ "$VERSION" = latest ]; then
  TAG=$(curl -sf "https://api.github.com/repos/PBH-BTN/PeerBanHelper/releases/latest" | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')
  VERSION=${TAG#v}
fi
ALPINE_VERSION="${2:-3.24}"

podman build --quiet --build-arg PBH_VERSION="$VERSION" --build-arg ALPINE_VERSION="$ALPINE_VERSION" -t "localhost/peerbanhelper:${VERSION}" -f Containerfile .
