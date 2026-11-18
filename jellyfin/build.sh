#!/bin/sh
# jellyfin 构建脚本：./build.sh [UPSTREAM_TAG]
# 详见 总结.md §4.1
set -e
cd "$(dirname "$0")"

UPSTREAM="${1:-latest}"
if [ "$UPSTREAM" = latest ]; then
  UPSTREAM=$(curl -sf "https://hub.docker.com/v2/repositories/nyanmisaka/jellyfin/tags?page_size=100" | grep -o '"name":"[^"]*"' | cut -d'"' -f4 | grep -E '^[0-9]{6}-amd64' | sort -r | head -1)
fi
VERSION=${UPSTREAM%%-*}

podman build --quiet --build-arg UPSTREAM_TAG="$UPSTREAM" --build-arg UPSTREAM_VERSION="$VERSION" -t "localhost/jellyfin:${VERSION}" -f Containerfile .
