#!/bin/sh
# 检测镜像上游最新版本，跟 GHCR 上已有的 tag 比对，输出需要构建的镜像清单
# 用法: sh .github/check.sh >> "$GITHUB_OUTPUT"；检测原理、踩过的坑见 总结.md §6.2
set -e

IMAGES="jellyfin mumble-server opencode peerbanhelper qbittorrentee rsshub"

gh_release() {
  curl -sf -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com/repos/$1/releases/latest" | grep -m1 '"tag_name"' | cut -d'"' -f4
}

list_tags() {
  TOKEN=$(curl -s -u "$GITHUB_ACTOR:$GITHUB_TOKEN" "https://ghcr.io/token?service=ghcr.io&scope=repository:nantayo/$1:pull" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
  # 包被删掉时 GHCR 会拒绝发 token 或 tags/list 返回 404/403，一律视为"没有 tag"→ 触发构建
  if [ -z "$TOKEN" ]; then
    echo "::warning::$1 拿不到 registry token（包可能已删除），按无 tag 处理" >&2
    echo '{"tags":[]}'
    return 0
  fi
  curl -s -H "Authorization: Bearer $TOKEN" "https://ghcr.io/v2/nantayo/$1/tags/list" || true
}

MATRIX="["

for IMAGE in $IMAGES; do
  UPSTREAM="" VERSION=""

  case "$IMAGE" in
    jellyfin)
      UPSTREAM=$(curl -sf "https://hub.docker.com/v2/repositories/nyanmisaka/jellyfin/tags?page_size=100" | grep -o '"name":"[^"]*"' | cut -d'"' -f4 | grep -E '^[0-9]{6}-amd64' | sort -r | head -1)
      VERSION=${UPSTREAM%%-*}
      ;;
    mumble-server)
      UPSTREAM=$(gh_release mumble-voip/mumble | sed 's/^v//')
      VERSION=$UPSTREAM
      ;;
    opencode)
      UPSTREAM=$(skopeo list-tags docker://ghcr.io/anomalyco/opencode | jq -r '.Tags[] | ltrimstr("v")' | grep -E '^2\.2\.[0-9]+$' | sort -t. -k3 -n | tail -1)
      VERSION=$UPSTREAM
      ;;
    peerbanhelper)
      UPSTREAM=$(gh_release PBH-BTN/PeerBanHelper | sed 's/^v//')
      VERSION=$UPSTREAM
      ;;
    qbittorrentee)
      UPSTREAM=$(gh_release c0re100/qBittorrent-Enhanced-Edition | sed 's/^release-//')
      VERSION=$UPSTREAM
      ;;
    rsshub)
      UPSTREAM=$(curl -sf "https://hub.docker.com/v2/repositories/diygod/rsshub/tags?page_size=100" | grep -o '"name":"[^"]*"' | cut -d'"' -f4 | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' | sort -r | head -1)
      VERSION=$(echo "$UPSTREAM" | tr -d '-')
      ;;
  esac

  [ -n "$VERSION" ] || { echo "::error::$IMAGE 取不到上游版本号" >&2; exit 1; }
  TAGS=$(list_tags "$IMAGE")
  if echo "$TAGS" | grep -q "\"$VERSION\""; then BUILD=false; else BUILD=true; fi

  echo "$IMAGE $VERSION build=$BUILD" >&2

  if [ "$BUILD" = "true" ]; then
    [ "$MATRIX" = "[" ] || MATRIX="$MATRIX,"
    MATRIX="$MATRIX{\"image\":\"$IMAGE\",\"upstream\":\"$UPSTREAM\",\"version\":\"$VERSION\"}"
  fi
done

echo "matrix=$MATRIX]"
