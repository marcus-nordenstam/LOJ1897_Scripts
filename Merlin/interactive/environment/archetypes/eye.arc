# One pair of eyes per human; capacity scales with human_npc cap (4096).
archetype "eye" (cap 4096) (mech obs) (non-occluder)
{
    "struct_parent"
    "obb"
    # PR-evi-A 2026-05-25 - per-body-part evidence attrs.
    "wounds"
    "stains"
    "marks"
}
