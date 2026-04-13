# Immobile parts of structures (walls, counters, windows, etc.) that occupy the env-grid
archetype "structure_part" [2048] /obs /always_visible /occupies_env_grid /children_occupy_env_grid
{
    "date"
    "name" /auto_percept
    "struct_parent"
    "parts" /auto_percept
    "obb"
}
