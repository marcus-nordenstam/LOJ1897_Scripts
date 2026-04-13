# Immobile parts of structures (walls, counters, windows, etc.) that occupy the env-grid
archetype "structure_part" [2048] /obs /always_visible /occupies_env_grid /sector_coverage
{
    "date"
    "name" /auto_percept
    "struct_parent"
    "parts" /auto_percept
    "obb"
}
