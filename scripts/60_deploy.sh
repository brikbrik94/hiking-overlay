#!/usr/bin/env bash
set -euo pipefail

SRC="${SRC:-$(pwd)/out/hiking.pmtiles}"
DEST="${DEST:-/srv/tiles/overlays/pmtiles/hiking.pmtiles}"

sudo cp -av "$DEST" "$DEST.bak.$(date +%F_%H%M%S)" 2>/dev/null || true
sudo install -D -m 0644 "$SRC" "$DEST.new"
sudo mv -f "$DEST.new" "$DEST"
echo "Deployed to: $DEST"
