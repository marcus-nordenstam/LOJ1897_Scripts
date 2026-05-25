# Two hands per human; capacity scales with human_npc cap (4096).
archetype "hand" (cap 8192) (mech obs) (non-occluder)
{
    "struct_parent"
    "parts"
    "ring_finger"
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
