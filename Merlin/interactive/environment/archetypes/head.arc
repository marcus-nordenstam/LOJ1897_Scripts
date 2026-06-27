# One head per human; capacity scales with human_npc cap (4096).
archetype "head" (cap 4096) (per obs) (non-occluder)
{
    "struct_parent"
    "obb"
    # PR-evi-A 2026-05-25 - per-body-part evidence attrs.
    "wounds"
    "stains"
    "marks"
}
