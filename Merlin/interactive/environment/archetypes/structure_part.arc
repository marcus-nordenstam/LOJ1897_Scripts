# Immobile parts of structures (walls, counters, windows, etc.) that occupy the env-grid
archetype "structure-part" (cap 4096) (per obs) (always-visible) (occupies-env-grid) (children-occupy-env-grid)
{
    # Kind-variation identity (see shared/attrs.arc).
    (attr "variant")
    (attr "birth-date")
    # Structure-part name is observable (engraving / placard).  ext-mech
    # override - common.arc leaves name imperceptible for the human model.
    (attr "name" (auto-percept) (ext-per obs))
    (spatial bounds)
    # Nav v2: openings (doors, gates, archways, large_windows) ride this
    # archetype as kind-distinguished children. /is-nav-passage gates the
    # macro-graph passage edge. The throat OBB and opening identity are
    # derived at scene-load from the entity's own TransformComponent and
    # its spatial relationship to nearby nav-meshes.
    (attr "is-nav-passage")
    # Opening state (doors / windows). Observable on sight so a thief can case a
    # lock. Non-opening parts (walls, counters) carry them unused. opening-status:
    # ajar | shut; lock-status: locked | unlocked (unset = not locked); integrity:
    # intact | broken (set broken when forced/smashed).
    (attr "opening-status" (auto-percept) (ext-per obs))
    (attr "lock-status"    (auto-percept) (ext-per obs))
    (attr "integrity"      (auto-percept) (ext-per obs))
    (attr "blemishes")
    # PR-evi-A 2026-05-25 - per-object evidence attrs. Blood-stains on
    # a wall, tool-marks on a door-jamb, gunpowder-residue on a counter.
}
