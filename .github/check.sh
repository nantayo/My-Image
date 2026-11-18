#!/bin/sh
set -e

IMAGES="jellyfin mumble-server opencode peerbanhelper qbittorrentee rsshub"

gh_tag() {
  curl -sf -H "Authorization: Bearer $GITHUB_TOKEN" "https://api.github.com/repos/$1/releases/latest" | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p'
}

hub_tags() {
  curl -sf "https://hub.docker.com/v2/repositories/$1/tags?page_size=100" | grep -o '"name":"[^"]*"' | cut -d'"' -f4
}

list_tags() {
  TOKEN=$(curl -s -u "$GITHUB_ACTOR:$GITHUB_TOKEN" "https://ghcr.io/token?service=ghcr.io&scope=repository:nantayo/$1:pull" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
  [ -n "$TOKEN" ] || { echo "::warning::$1 拿不到 registry token，按无 tag 处理" >&2; echo '{"tags":[]}'; return 0; }
  curl -s -H "Authorization: Bearer $TOKEN" "https://ghcr.io/v2/nantayo/$1/tags/list" || true
}

MATRIX="["

for IMAGE in $IMAGES; do
  case "$IMAGE" in
    jellyfin)
      UPSTREAM=$(hub_tags nyanmisaka/jellyfin | grep -E '^[0-9]{6}-amd64' | sort -r | head -1)
      VERSION=${UPSTREAM%%-*}
      ;;
    mumble-server)
      UPSTREAM=$(gh_tag mumble-voip/mumble | sed 's/^v//')
      VERSION=$UPSTREAM
      ;;
    opencode)
      UPSTREAM=$(skopeo list-tags docker://ghcr.io/anomalyco/opencode | jq -r '.Tags[] | ltrimstr("v")' | grep -E '^2\.[0-9]+\.[0-9]+$' | sort -t. -k1,1n -k2,2n -k3,3n | tail -1)
      VERSION=$UPSTREAM
      ;;
    peerbanhelper)
      UPSTREAM=$(gh_tag PBH-BTN/PeerBanHelper | sed 's/^v//')
      VERSION=$UPSTREAM
      ;;
    qbittorrentee)
      UPSTREAM=$(gh_tag c0re100/qBittorrent-Enhanced-Edition | sed 's/^release-//')
      VERSION=$UPSTREAM
      ;;
    rsshub)
      UPSTREAM=$(hub_tags diygod/rsshub | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' | sort -r | head -1)
      VERSION=$(echo "$UPSTREAM" | tr -d -)
      ;;
  esac

  [ -n "$VERSION" ] || { echo "::error::$IMAGE 取不到上游版本号" >&2; exit 1; }
  TAGS=$(list_tags "$IMAGE")
  if echo "$TAGS" | grep -q "\"$VERSION\""; then BUILD=false; else BUILD=true; fi

  echo "$IMAGE $VERSION build=$BUILD" >&2

  [ "$BUILD" = true ] || continue
  [ "$MATRIX" = "[" ] || MATRIX="$MATRIX,"
  MATRIX="$MATRIX{\"image\":\"$IMAGE\",\"upstream\":\"$UPSTREAM\",\"version\":\"$VERSION\"}"
done

echo "matrix=$MATRIX]"
