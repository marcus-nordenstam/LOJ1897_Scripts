# Ring-fingers only - 2 per human; capacity scales with hand cap.
archetype "finger" (cap 8192) (per obs) (non-occluder)
{
    # Placement participation (plan section 18): which spatial relations this
    # archetype takes part in - the write seams validate both ends.
    (spatial control)
    (attr "wear")
    (attr "control")
    (attr "obb")
    # PR-evi-A 2026-05-25 - per-body-part evidence attrs.
    (attr "wounds")
    (attr "stains")
    (attr "marks")
}
