# hiking-overlay (PMTiles)

This repo documents and reproduces the pipeline we built on your Debian server to generate a **hiking overlay for Austria** as **PMTiles**.

It creates a single `hiking.pmtiles` containing these vector layers:

- `hiking_low` — zoom 6–10 (only iwn/nwn; low-detail overview)
- `hiking_high` — zoom 11–14 (iwn/nwn/rwn/lwn; detailed network)
- `via_ferrata` — zoom 11–14 (Klettersteige)
- `hiking_extra` — zoom 13–14 (additional hiking-relevant paths **not** in route relations; e.g. `sac_scale` / `trail_visibility`)

> Why `hiking_extra`?
> Waymarked/route-based rendering only includes ways that are members of `type=route` relations. Many real hiking paths in OSM are tagged as paths (e.g. `highway=path` + `sac_scale=*`) but are **not** in a route relation. `hiking_extra` fills that gap without importing “every path”.

---

## Quick start (one-time)

### 0) System dependencies

```bash
sudo apt-get update
sudo apt-get install -y postgresql postgresql-contrib postgis gdal-bin osm2pgsql python3 python3-venv python3-pip tippecanoe
# optional but useful:
sudo apt-get install -y python3-psycopg2 python3-pyosmium
```

### 1) Create DB + extensions

```bash
sudo -u postgres psql -c "CREATE USER hiking WITH PASSWORD 'hiking';"
sudo -u postgres psql -c "CREATE DATABASE hikingtest OWNER hiking;"
sudo -u postgres psql -d hikingtest -c "CREATE EXTENSION postgis;"
sudo -u postgres psql -d hikingtest -c "CREATE EXTENSION hstore;"
```

### 2) Download PBF

```bash
mkdir -p /root/hiking-test && cd /root/hiking-test
curl -L -o austria-latest.osm.pbf https://download.geofabrik.de/europe/austria-latest.osm.pbf
```

---

## Run the pipeline (step-by-step)

All scripts assume:

- PBF: `/root/hiking-test/austria-latest.osm.pbf`
- DB:  `hikingtest` user `hiking` password `hiking` on `127.0.0.1`

### Step A — Import basic OSM tables with osm2pgsql flex

This imports:
- **all ways** (so relations can reference them)
- **only hiking route relations** into `hiking_rel`

```bash
cd /root/hiking-test
./scripts/10_import_osm2pgsql.sh
```

### Step B — Build relation→way membership table

`osm2pgsql` flex doesn’t give us a relation-member table in this setup. We create it ourselves:

- Create table `hiking_rel_way`
- Parse the PBF with `pyosmium`
- Insert (rel_id, way_id, role) links for relation way-members

```bash
cd /root/hiking-test
./scripts/20_extract_rel_ways.sh
```

### Step C — Create SQL views that define the overlay content

Creates:
- `hiking_route_line` (joined relation + member ways)
- `hiking_best_way` (deduplicate by taking the “best” network per way)
- `hiking_extra_ways` (hiking-relevant paths outside route relations)
- `via_ferrata_lines` (Klettersteige subset)

```bash
cd /root/hiking-test
./scripts/30_create_views.sh
```

### Step D — Export GeoJSONSeq for tippecanoe

```bash
cd /root/hiking-test
./scripts/40_export_geojsonseq.sh
```

### Step E — Build PMTiles and combine reliably

We build separate PMTiles first, then combine with **tile-join**.
We prefer `tile-join` over `pmtiles merge` here because some inputs overlap in Z/X/Y
(merge requires disjoint tiles).

```bash
cd /root/hiking-test
./scripts/50_build_pmtiles.sh
```

Output:
- `at-hiking-low.pmtiles`
- `at-hiking-high.pmtiles`
- `via_ferrata.pmtiles`
- `hiking_extra.pmtiles`
- **final:** `hiking.pmtiles`

### Step F — Deploy (atomically) to the tile server directory

Edit the destination path in `scripts/60_deploy.sh` if needed.

```bash
cd /root/hiking-test
./scripts/60_deploy.sh
```

---

## Style JSON

A ready-to-use MapLibre style lives in:

- `styles/hiking.style.json`

It expects:
- PMTiles at `https://tiles.oe5ith.at/overlays/pmtiles/hiking.pmtiles`
- Glyphs at `https://tiles.oe5ith.at/assets/fonts/{fontstack}/{range}.pbf`

---

## Repo bootstrap (Git)

```bash
git init
git add .
git commit -m "Initial hiking overlay pipeline"
```
