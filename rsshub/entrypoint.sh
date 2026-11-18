#!/bin/sh
# 无参数、首参为选项或不是可执行命令时补 node
set -e
if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ] || { [ -f "${1}" ] && ! [ -x "${1}" ]; }; then
  set -- node "$@"
fi
exec "$@"
