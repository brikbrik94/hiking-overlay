#!/usr/bin/env bash
set -euo pipefail

export PGPASSWORD="${PGPASSWORD:-hiking}"
DB="${DB:-hikingtest}"
HOST="${HOST:-127.0.0.1}"
USER="${USER:-hiking}"

psql -P pager=off -h "$HOST" -U "$USER" -d "$DB" -f "$(pwd)/sql/views.sql"
