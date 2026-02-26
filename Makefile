.PHONY: import members views export build deploy

import:
	./scripts/10_import_osm2pgsql.sh

members:
	./scripts/20_extract_rel_ways.sh

views:
	./scripts/30_create_views.sh

export:
	./scripts/40_export_geojsonseq.sh

build:
	./scripts/50_build_pmtiles.sh

deploy:
	./scripts/60_deploy.sh
