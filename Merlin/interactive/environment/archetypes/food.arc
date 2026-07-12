# Food items (bread, cheese, soup, etc.) - parallel to fluid. Tampering /
# poisoning is recorded via the `add_substance` verb-state in States.mon
# (PR-evi-C 2026-05-25, migrated from the retired `tainted_with` attr).
archetype "food" (cap 8192) (per obs) (occupies-env-grid) (non-occluder)
{
    "controlled_by"
    # Where the morsel sits - seam-derived from the OBB like every prop.
    # Perceptible: the room walk mints the {<morsel> location <room>}
    # whereabouts beliefs the meal economy's stock gates read
    # ((count-believed-located [k food] ...) - per-mind, never a world scan).
    "location"
    "obb"
}
