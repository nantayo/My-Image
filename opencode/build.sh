# opencode 镜像（直接 pull 上游 + tag，不构建，故无 Containerfile）
# 精简方案、适配方法与实测数据见 总结.md

VERSION="${1:-latest}"
if [ "$VERSION" = "latest" ]; then
  VERSION=$(skopeo list-tags docker://ghcr.io/anomalyco/opencode | jq -r '.Tags[] | ltrimstr("v")' | grep -E '^2\.0\.[0-9]+$' | sort -t. -k3 -n | tail -1)
fi

podman pull --quiet "ghcr.io/anomalyco/opencode:$VERSION"
podman tag "ghcr.io/anomalyco/opencode:$VERSION" "localhost/opencode:$VERSION"
podman tag "localhost/opencode:$VERSION" localhost/opencode:latest
