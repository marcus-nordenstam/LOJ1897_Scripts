# Immobile structures with their own internal cell-space (buildings, ships, wagons, train_cars).
# Distinguished from `structure` (pier, bridge) by having a container_id (auto-injected in code, not listed here).
archetype "container_structure" (cap 2048) (mech obs) (always-visible) (children-occupy-env-grid)
{
    "birth_date"
    # Name is auto-perceived so NPCs know what building they're in.  The
    # ext-mech override (common.arc names default to imperceptible for humans)
    # lets the visual sensor tag perceived building-name beliefs as OBS so
    # they live in the OBS pool.  Stopgap until address signs become
    # observable entities.
    "name" (auto-percept) (ext-mech obs)
    "parts" (auto-percept)
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
    # Delta-driven prop perception: last prop add/remove date (see
    # common.arc). Stays on the BUILDING (perception is building-granular: an
    # occupant takes in the whole dwelling); a prop added to any of its rooms
    # bumps this stamp via bump_inventory_stamp. The loose-item `contents`
    # index itself now lives PER-ROOM on interior_space / exterior_space.
    "inventory_changed"
    # Nav v2: cache key into nav_graph's mesh-data table.
    "nav_mesh"
    # Nav v2: container_structures (buildings/ships/wagons) physically occupy
    # their footprint - rasterise as terrain blockers so terrain pathfinding
    # routes around them. Connector throat clearing (§7.3) re-opens the cells
    # under each baked passage so doors stay walkable.
    "blocks_nav_terrain"
}
