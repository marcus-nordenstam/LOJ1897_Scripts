# Food items (bread, cheese, soup, etc.) - parallel to fluid. Tampering /
# poisoning is recorded via the `add_substance` verb-state in States.mon
# (PR-evi-C 2026-05-25, migrated from the retired `tainted_with` attr).
archetype "food" (cap 256) (per obs) (occupies-env-grid) (non-occluder)
{
    "controlled_by"
    "obb"
}
