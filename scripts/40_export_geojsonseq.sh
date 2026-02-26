#!/usr/bin/env bash
set -euo pipefail

export PGPASSWORD="${PGPASSWORD:-hiking}"
DB="${DB:-hikingtest}"
HOST="${HOST:-127.0.0.1}"
USER="${USER:-hiking}"

mkdir -p out

ogr2ogr -f GeoJSONSeq out/hiking_low.geojsonseq   PG:"host=$HOST dbname=$DB user=$USER password=$PGPASSWORD"   -nln hiking_low -nlt LINESTRING -t_srs EPSG:4326   -sql "
    SELECT way_id, rel_id, network, ref, name, osmc_symbol,
           ST_Transform(geom, 4326) AS geom
    FROM hiking_best_way
    WHERE network IN ('iwn','nwn')
  "

ogr2ogr -f GeoJSONSeq out/hiking_high.geojsonseq   PG:"host=$HOST dbname=$DB user=$USER password=$PGPASSWORD"   -nln hiking_high -nlt LINESTRING -t_srs EPSG:4326   -sql "
    SELECT way_id, rel_id, network, ref, name, osmc_symbol,
           ST_Transform(geom, 4326) AS geom
    FROM hiking_best_way
    WHERE network IN ('iwn','nwn','rwn','lwn')
  "

ogr2ogr -f GeoJSONSeq out/hiking_extra.geojsonseq   PG:"host=$HOST dbname=$DB user=$USER password=$PGPASSWORD"   -nln hiking_extra -nlt LINESTRING -t_srs EPSG:4326   -sql "
    SELECT way_id, highway, name, ref, sac_scale, trail_visibility,
           trailblazed, "trailblazed:visibility", description,
           ST_Transform(geom, 4326) AS geom
    FROM hiking_extra_ways
  "

ogr2ogr -f GeoJSONSeq out/via_ferrata.geojsonseq   PG:"host=$HOST dbname=$DB user=$USER password=$PGPASSWORD"   -nln via_ferrata -nlt LINESTRING -t_srs EPSG:4326   -sql "
    SELECT way_id, via_ferrata_scale, via_ferrata_scale_label, name, ref,
           ST_Transform(geom, 4326) AS geom
    FROM via_ferrata_lines
  "
