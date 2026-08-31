# Exterior spaces (Section 4.12): the outdoor half of the space split. Per-address
# street frontages (street_space), amenity grounds (garden/field/park), remote
# named wilds (meadow/forest/moor/bluff/cliff), and the administrative regions
# (land/territory/area/neighborhood). Bound by kind: a leaf like `street_space`
# walks street_space -> exterior-space, hitting this archetype before the abstract
# `space` root. Exterior spaces carry a street address (-> road) + address-number
# when they front a road; remote wilds are name-only.
# cap: ~579 per-address street_spaces + a handful of areas/neighborhoods + the
# P4 amenity/wild spaces + a century of runtime spawns.
archetype "exterior-space" (cap 4096) (per obs) (always-visible) (non-occluder) (sector-coverage)
{
    # Kind-variation identity (see shared/attrs.arc).
    (attr "variant")
    (attr "birth-date")
    # Name is auto-perceived so NPCs know what space they're in (e.g. "the moors",
    # "Julie's Meadow"). The ext-mech override lands perceived name beliefs in the
    # OBS pool. Stopgap until address signs become observable entities.
    (attr "name" (auto-percept) (ext-per obs))
    (spatial bounds)
    # Nav v2: spaces can host openings whose /is-nav-passage gates a macro-graph edge.
    (attr "is-nav-passage")
    # The address lives ON the premise: the road this exterior space fronts +
    # its street number. (Both a building and an addressed exterior-space carry
    # their own `address` -> road; there is no street_space frontage box.) Unset
    # for remote wilds.
    (attr "address")
    (attr "address-number")
    # NO `contents` index: exterior spaces are unbounded, so they keep no
    # loose-item inverse. They remain valid `location` targets (the env seam
    # still sets an outdoor entity's location to the smallest exterior space
    # holding its OBB center); outdoor occupancy queries scan the forward
    # `location` attr instead (hsim occupants_at fallback).
}
