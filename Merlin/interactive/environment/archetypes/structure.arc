# Immobile structures without an internal cell-space (pier, bridge).
# Buildings, ships, wagons and train_cars use the `container_structure`
# archetype instead - that one carries a container_id.
archetype "structure" (cap 256) (mech obs) (always-visible) (children-occupy-env-grid)
{
    "birth_date"
    # Name is auto-perceived so NPCs know what they're at.  The ext-mech
    # override re-enables visual perception of the structure's name (common.arc
    # leaves it imperceptible because human names aren't seen).  Stopgap until
    # address signs become observable entities in their own right.
    "name" (auto-percept) (ext-mech obs)
    "parts" (auto-percept)
    "obb"
    "era_min"
    "era_max"
    # Address - road the structure is on (piers/bridges sit on a road).
    "address"
    "address_number"
    "region"
    # Nav v2: cache key into nav_graph's mesh-data table (set by Player at
    # scene load on entities with a baked .nvm in their MerlinComponent).
    "nav_mesh"
    # Nav v2: when 1, the structure rasterises into the static-obstacle index
    # at t_nav_terrain::build time (nav_v2_plan.md §7.1). Default 0 here so
    # piers/bridges (which span open ground) don't accidentally block the
    # terrain underneath them; container_structure overrides to 1 because
    # buildings physically occupy their footprint.
    "blocks_nav_terrain"
}
