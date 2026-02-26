#!/usr/bin/env bash
set -euo pipefail

mkdir -p out

tippecanoe -o out/at-hiking-low.pmtiles --force --read-parallel   --minimum-zoom=6 --maximum-zoom=10   --drop-densest-as-needed --extend-zooms-if-still-dropping   -l hiking_low out/hiking_low.geojsonseq

tippecanoe -o out/at-hiking-high.pmtiles --force --read-parallel   --minimum-zoom=11 --maximum-zoom=14   --drop-densest-as-needed --extend-zooms-if-still-dropping   -l hiking_high out/hiking_high.geojsonseq

tippecanoe -o out/hiking_extra.pmtiles --force --read-parallel   --minimum-zoom=13 --maximum-zoom=14   --drop-densest-as-needed --extend-zooms-if-still-dropping   -l hiking_extra out/hiking_extra.geojsonseq

tippecanoe -o out/via_ferrata.pmtiles --force --read-parallel   --minimum-zoom=11 --maximum-zoom=14   --drop-densest-as-needed --extend-zooms-if-still-dropping   -l via_ferrata out/via_ferrata.geojsonseq

tile-join --force -o out/hiking.pmtiles   out/at-hiking-low.pmtiles   out/at-hiking-high.pmtiles   out/hiking_extra.pmtiles   out/via_ferrata.pmtiles

echo "Built: out/hiking.pmtiles"
