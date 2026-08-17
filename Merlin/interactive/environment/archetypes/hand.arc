# Two hands per human; capacity scales with human_npc cap (4096).
archetype "hand" (cap 8192) (per obs) (non-occluder)
{
    # The hand's own sub-structure (plan section 18): rides along wherever a hand
    # is created.
    (struct child "ring_finger" [k ring_finger] (offset 0 0 0))
    "wear"
    "control"
    "obb"
    # PR-evi-A 2026-05-25 - per-body-part evidence attrs. Wounds,
    # blood-stains on hand, scratch-marks etc. The transmitter plural-
    # expands these into repeated singular `{?hand wound|stain|mark
    # <atom>}` beliefs.
    "wounds"
    "stains"
    "marks"
}
