# Immobile structures without an internal cell-space (pier, bridge).
# Buildings, ships, wagons and train_cars use the `container_structure`
# archetype instead - that one carries a container_id.
archetype "structure" [256] /obs /always_visible /children_occupy_env_grid
{
    "date"
    # Name is auto-perceived so NPCs know what they're at
    "name" /auto_percept
    "parts" /auto_percept
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
}
