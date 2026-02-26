#!/usr/bin/env bash
set -euo pipefail

PBF="${PBF:-/root/hiking-test/austria-latest.osm.pbf}"
LUA="${LUA:-$(pwd)/sql/osm2pgsql-hiking.lua}"

export PGPASSWORD="${PGPASSWORD:-hiking}"
DB="${DB:-hikingtest}"
HOST="${HOST:-127.0.0.1}"
USER="${USER:-hiking}"

osm2pgsql   -O flex   -S "$LUA"   -d "$DB" -U "$USER" -H "$HOST"   --create --slim   --cache 2000   --number-processes 4   "$PBF"
