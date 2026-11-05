#!/bin/sh
set -e
if [ ! -f /data/mumble-server.ini ]; then
  sed -E -e 's|^[#;]?database=.*|database=/data/mumble-server.sqlite|' -e 's|^[#;]?logfile=.*|logfile=|' /etc/mumble/mumble-server.ini > /data/mumble-server.ini
fi
exec /usr/bin/mumble-server -fg -ini /data/mumble-server.ini
