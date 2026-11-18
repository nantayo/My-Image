#!/bin/sh
# opencode 构建脚本：./build.sh [VERSION]
# 详见 总结.md §4.4
set -e
cd "$(dirname "$0")"

VERSION="${1:-latest}"
if [ "$VERSION" = latest ]; then
  VERSION=$(skopeo list-tags docker://ghcr.io/anomalyco/opencode | jq -r '.Tags[] | ltrimstr("v")' | grep -E '^2\.[0-9]+\.[0-9]+$' | sort -t. -k1,1n -k2,2n -k3,3n | tail -1)
fi

podman build --quiet --build-arg VERSION="$VERSION" -t "localhost/opencode:${VERSION}" -f Containerfile .
