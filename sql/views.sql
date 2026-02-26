DROP VIEW IF EXISTS hiking_route_line;
CREATE VIEW hiking_route_line AS
SELECT
  rw.rel_id,
  rw.way_id,
  rw.role,
  r.network,
  r.ref,
  r.name,
  r.osmc_symbol,
  r.operator,
  r.route,
  w.highway,
  w.sac_scale,
  w.trail_visibility,
  w.surface,
  w.tracktype,
  w.geom
FROM hiking_rel_way rw
JOIN hiking_rel r ON r.osm_id = rw.rel_id
JOIN hiking_way w ON w.osm_id = rw.way_id;

DROP VIEW IF EXISTS hiking_best_way;
CREATE VIEW hiking_best_way AS
WITH ranked AS (
  SELECT
    way_id,
    rel_id,
    network,
    ref,
    name,
    osmc_symbol,
    geom,
    CASE network
      WHEN 'iwn' THEN 4
      WHEN 'nwn' THEN 3
      WHEN 'rwn' THEN 2
      WHEN 'lwn' THEN 1
      ELSE 0
    END AS prio,
    ROW_NUMBER() OVER (
      PARTITION BY way_id
      ORDER BY
        CASE network
          WHEN 'iwn' THEN 4
          WHEN 'nwn' THEN 3
          WHEN 'rwn' THEN 2
          WHEN 'lwn' THEN 1
          ELSE 0
        END DESC,
        rel_id DESC
    ) AS rn
  FROM hiking_route_line
)
SELECT
  way_id, rel_id, network, ref, name, osmc_symbol, geom
FROM ranked
WHERE rn = 1;

DROP VIEW IF EXISTS hiking_extra_ways;
CREATE VIEW hiking_extra_ways AS
SELECT
  w.osm_id AS way_id,
  w.highway AS highway,
  w.tags->>'name' AS name,
  w.tags->>'ref'  AS ref,
  w.tags->>'sac_scale' AS sac_scale,
  w.tags->>'trail_visibility' AS trail_visibility,
  w.tags->>'trailblazed' AS trailblazed,
  w.tags->>'trailblazed:visibility' AS "trailblazed:visibility",
  w.tags->>'description' AS description,
  w.geom
FROM hiking_way w
LEFT JOIN hiking_best_way b ON b.way_id = w.osm_id
WHERE
  b.way_id IS NULL
  AND w.highway IN ('path','footway','track','steps')
  AND NOT (w.tags ? 'via_ferrata_scale')
  AND (
       w.tags ? 'sac_scale'
    OR w.tags ? 'trail_visibility'
    OR w.tags ? 'trailblazed'
    OR w.tags ? 'trailblazed:visibility'
  );

DROP VIEW IF EXISTS via_ferrata_lines;
CREATE VIEW via_ferrata_lines AS
SELECT
  w.osm_id AS way_id,
  w.tags->>'via_ferrata_scale' AS via_ferrata_scale,
  NULLIF(w.tags->>'via_ferrata_scale_label','') AS via_ferrata_scale_label,
  w.tags->>'name' AS name,
  w.tags->>'ref' AS ref,
  w.geom
FROM hiking_way w
WHERE
  w.tags ? 'via_ferrata_scale';
