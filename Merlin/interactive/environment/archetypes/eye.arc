# One pair of eyes per human; capacity scales with human_npc cap (4096).
archetype "eye" (cap 4096) (per obs) (non-occluder)
{
    (spatial bounds)
    # PR-evi-A 2026-05-25 - per-body-part evidence attrs.
    (attr "wounds")
    (attr "stains")
    (attr "marks")
}
