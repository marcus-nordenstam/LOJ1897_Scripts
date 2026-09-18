# One right hand per human; capacity covers human-npc (4096) + human-player (256).
#
# Split from a single "hand" archetype because (struct child ...) decls are read off
# the PARENT'S ARCHETYPE, not its kind: one shared archetype can only name one
# ring-finger kind, and the two hands need different ones so each ring finger carries
# its own rig bone.
archetype "right-hand" (cap 4352) (per obs) (non-occluder)
{
    # Placement participation (plan section 18): which spatial relations this
    # archetype takes part in - the write seams validate both ends.
    (spatial grip)
    # The hand's own sub-structure (plan section 18): rides along wherever a hand
    # is created.
    (struct child "ring-finger" [k right-ring-finger] (offset 0 0 0))
    (attr "wear")
    (spatial bounds)
    # PR-evi-A 2026-05-25 - per-body-part evidence attrs. Wounds,
    # blood-stains on hand, scratch-marks etc. The transmitter plural-
    # expands these into repeated singular `{?hand wound|stain|mark
    # <atom>}` beliefs.
    (attr "blemishes")
}
