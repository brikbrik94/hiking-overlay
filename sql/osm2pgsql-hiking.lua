-- osm2pgsql flex config for hiking overlay
-- Creates:
--   hiking_way (all ways with geometry + tags)
--   hiking_rel (filtered hiking route relations)

local tables = {}

tables.ways = osm2pgsql.define_way_table('hiking_way', {
  { column = 'osm_id', type = 'bigint', not_null = true },
  { column = 'geom', type = 'linestring', not_null = true },
  { column = 'highway', type = 'text' },
  { column = 'sac_scale', type = 'text' },
  { column = 'trail_visibility', type = 'text' },
  { column = 'surface', type = 'text' },
  { column = 'tracktype', type = 'text' },
  { column = 'tags', type = 'jsonb' }
})

tables.rels = osm2pgsql.define_relation_table('hiking_rel', {
  { column = 'osm_id', type = 'bigint', not_null = true },
  { column = 'type', type = 'text' },
  { column = 'route', type = 'text' },
  { column = 'network', type = 'text' },
  { column = 'ref', type = 'text' },
  { column = 'name', type = 'text' },
  { column = 'osmc_symbol', type = 'text' },
  { column = 'operator', type = 'text' },
  { column = 'state', type = 'text' },
  { column = 'tags', type = 'jsonb' }
})

local function is_hiking_relation(tags)
  if tags.type ~= 'route' and tags.type ~= 'superroute' then
    return false
  end
  if tags.state == 'proposed' then
    return false
  end
  if not tags.route then
    return false
  end
  if string.find(tags.route, 'hiking') or string.find(tags.route, 'foot') or string.find(tags.route, 'walking') then
    return true
  end
  return false
end

function osm2pgsql.process_way(object)
  tables.ways:insert({
    osm_id = object.id,
    geom = object:as_linestring(),
    highway = object.tags.highway,
    sac_scale = object.tags.sac_scale,
    trail_visibility = object.tags.trail_visibility,
    surface = object.tags.surface,
    tracktype = object.tags.tracktype,
    tags = object.tags
  })
end

function osm2pgsql.process_relation(object)
  if not is_hiking_relation(object.tags) then
    return
  end

  tables.rels:insert({
    osm_id = object.id,
    type = object.tags.type,
    route = object.tags.route,
    network = object.tags.network,
    ref = object.tags.ref,
    name = object.tags.name,
    osmc_symbol = object.tags['osmc:symbol'],
    operator = object.tags.operator,
    state = object.tags.state,
    tags = object.tags
  })
end
