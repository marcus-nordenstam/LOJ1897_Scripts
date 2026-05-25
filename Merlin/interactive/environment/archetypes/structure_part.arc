# Immobile parts of structures (walls, counters, windows, etc.) that occupy the env-grid
archetype "structure_part" (cap 2048) (mech obs) (always-visible) (occupies-env-grid) (children-occupy-env-grid)
{
    "birth_date"
    # Structure-part name is observable (engraving / placard).  ext-mech
    # override - common.arc leaves name imperceptible for the human model.
    "name" (auto-percept) (ext-mech obs)
    "struct_parent"
    "parts" (auto-percept)
    "obb"
    # Nav v2: openings (doors, gates, archways, large_windows) ride this
    # archetype as kind-distinguished children. /is_nav_passage gates the
    # macro-graph passage edge. The throat OBB and opening identity are
    # derived at scene-load from the entity's own TransformComponent and
    # its spatial relationship to nearby nav-meshes.
    "is_nav_passage"
    # PR-evi-A 2026-05-25 - per-object evidence attrs. Blood-stains on
    # a wall, tool-marks on a door-jamb, gunpowder-residue on a counter.
    "stains"
    "marks"
}
