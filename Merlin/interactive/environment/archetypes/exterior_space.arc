# Exterior spaces (Section 4.12): the outdoor half of the space split. Per-address
# street frontages (street_space), amenity grounds (garden/field/park), remote
# named wilds (meadow/forest/moor/bluff/cliff), and the administrative regions
# (land/territory/area/neighborhood). Bound by kind: a leaf like `street_space`
# walks street_space -> exterior_space, hitting this archetype before the abstract
# `space` root. Exterior spaces carry a street address (-> road) + address_number
# when they front a road; remote wilds are name-only.
# cap: ~579 per-address street_spaces + a handful of areas/neighborhoods + the
# P4 amenity/wild spaces + a century of runtime spawns.
archetype "exterior_space" (cap 4096) (mech obs) (always-visible) (non-occluder) (sector-coverage)
{
    "birth_date"
    # Name is auto-perceived so NPCs know what space they're in (e.g. "the moors",
    # "Julie's Meadow"). The ext-mech override lands perceived name beliefs in the
    # OBS pool. Stopgap until address signs become observable entities.
    "name" (auto-percept) (ext-mech obs)
    "struct_parent"
    "parts" (auto-percept)
    "obb"
    # Nav v2: spaces can host openings whose /is_nav_passage gates a macro-graph edge.
    "is_nav_passage"
    # Exterior address-spaces: the road this space fronts + its street number. A
    # building's `address` points to its address-space; the space's own `address`
    # points to the road. Unset for remote wilds.
    "address"
    "address_number"
    # Per-space loose-item index (inverse of each prop's `location`): props
    # dropped in this outdoor space (a weapon flung in a street / field). The
    # confrontation grab and acquisition read it the same as a room's. Maintained
    # by hsim set_prop_location.
    "contents"
}
