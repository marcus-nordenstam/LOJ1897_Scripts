# Immobile parts of structures (walls, counters, windows, etc.) that occupy the env-grid
archetype "structure_part" [2048] /obs /always_visible /occupies_env_grid /children_occupy_env_grid
{
    "birth_date"
    "name" /auto_percept
    "struct_parent"
    "parts" /auto_percept
    "obb"
    # Nav v2: openings (doors, gates, archways, large_windows) ride this
    # archetype as kind-distinguished children. /is_nav_passage gates the
    # macro-graph passage edge. The throat OBB and opening identity are
    # derived at scene-load from the entity's own TransformComponent and
    # its spatial relationship to nearby nav-meshes.
    "is_nav_passage"
}
