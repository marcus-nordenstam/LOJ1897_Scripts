# Two hands per human; capacity scales with human_npc cap (4096).
archetype "hand" (cap 8192) (per obs) (non-occluder)
{
    # Placement participation (plan section 18): which spatial relations this
    # archetype takes part in - the write seams validate both ends.
    (spatial grip)
    # The hand's own sub-structure (plan section 18): rides along wherever a hand
    # is created.
    (struct child "ring_finger" [k ring_finger] (offset 0 0 0))
    (attr "wear")
    (attr "obb")
    # PR-evi-A 2026-05-25 - per-body-part evidence attrs. Wounds,
    # blood-stains on hand, scratch-marks etc. The transmitter plural-
    # expands these into repeated singular `{?hand wound|stain|mark
    # <atom>}` beliefs.
    (attr "wounds")
    (attr "stains")
    (attr "marks")
}
