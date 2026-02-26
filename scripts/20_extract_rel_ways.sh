#!/usr/bin/env bash
set -euo pipefail

export PGPASSWORD="${PGPASSWORD:-hiking}"
DB="${DB:-hikingtest}"
HOST="${HOST:-127.0.0.1}"
USER="${USER:-hiking}"

psql -P pager=off -h "$HOST" -U "$USER" -d "$DB" -c "
DROP TABLE IF EXISTS hiking_rel_way;
CREATE TABLE hiking_rel_way (
  rel_id bigint NOT NULL,
  way_id bigint NOT NULL,
  role text
);
CREATE INDEX hiking_rel_way_rel_id_idx ON hiking_rel_way(rel_id);
CREATE INDEX hiking_rel_way_way_id_idx ON hiking_rel_way(way_id);
"

python3 "$(pwd)/scripts/extract_rel_ways.py"
