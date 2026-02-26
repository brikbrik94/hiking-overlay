# hiking-overlay – Process Notes (step-by-step)

## 1) Data source
We start from an OSM extract for Austria: `austria-latest.osm.pbf` (Geofabrik).

## 2) Why a database?
PostgreSQL + PostGIS makes it easy to filter relations, join to way geometries, and export clean layers.

## 3) osm2pgsql flex import
We import:
- all ways into `hiking_way`
- hiking route relations into `hiking_rel` (filtered by tags)

## 4) Relation members
Because the minimal flex import does not produce a relation-member table, we create `hiking_rel_way` by parsing the PBF with `pyosmium`.

## 5) Joined route view
`hiking_route_line` joins relation attributes to member way geometries.

## 6) De-duplication
`hiking_best_way` picks the best network per `way_id` (iwn > nwn > rwn > lwn) to avoid duplicates and excessive density.

## 7) Extra hiking paths
`hiking_extra_ways` adds hiking-relevant ways outside relations (e.g. `sac_scale`, `trail_visibility`), while excluding already-included ways and avoiding a “download every path” overlay.

## 8) Via ferrata
`via_ferrata_lines` selects via ferrata ways via `via_ferrata_scale`.

## 9) Export + PMTiles
We export to GeoJSONSeq with `ogr2ogr`, then build PMTiles with `tippecanoe`.

## 10) Combine
We combine with `tile-join` because some inputs overlap in Z/X/Y and we want layers preserved by name.
