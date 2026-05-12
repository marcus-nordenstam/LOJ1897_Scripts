# Immobile structures with their own internal cell-space (buildings, ships, wagons, train_cars).
# Distinguished from `structure` (pier, bridge) by having a container_id (auto-injected in code, not listed here).
archetype "container_structure" [2048] /obs /always_visible /children_occupy_env_grid
{
    "date"
    # Name is auto-perceived so NPCs know what building they're in
    "name" /auto_percept
    "parts" /auto_percept
    "obb"
    # Building physical / structural properties (historical sim writes
    # these; crime templates and behaviour rules may match on them).
    "isolated"
    "has_crypt"
    "locked_wing"
    "era_min"
    "era_max"
    # Address - road the building is on, OR self-reference for estates.
    # See common.arc for the _ convention on address_number.
    "address"
    "address_number"
    "region"
    # Nav v2: cache key into nav_graph's mesh-data table.
    "nav_mesh"
    # Nav v2: container_structures (buildings/ships/wagons) physically occupy
    # their footprint - rasterise as terrain blockers so terrain pathfinding
    # routes around them. Connector throat clearing (§7.3) re-opens the cells
    # under each baked passage so doors stay walkable.
    "blocks_nav_terrain"
}
