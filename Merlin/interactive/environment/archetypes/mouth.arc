# One mouth per human; capacity scales with human_npc cap (4096).
archetype "mouth" (cap 4096) (per obs) (non-occluder)
{
    (attr "obb")
    # PR-evi-A 2026-05-25 - per-body-part evidence attrs.
    (attr "wounds")
    (attr "stains")
    (attr "marks")
}
