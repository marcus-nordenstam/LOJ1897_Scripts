# Spaces - the universal occupiable-region archetype (Section 4.12): INTERIOR
# rooms AND EXTERIOR spaces (per-address frontage spaces, parks, gardens, fields,
# remote wilds).
# cap: ~2000 interior rooms + ~one exterior address-space per building (~588) +
# amenity/wild spaces + a century of runtime spawns, so the room-era 4096 is
# raised to 8192.
archetype "space" (cap 8192) (mech obs) (always-visible) (non-occluder) (sector-coverage)
{
    "birth_date"
    # Name is auto-perceived so NPCs know what space they're in.  The ext-mech
    # override (was inherited as imperceptible from common.arc, where names are
    # the human model) lets the visual sensor tag perceived space-name beliefs
    # as OBS, landing them in the OBS pool where confirm/disprove iterates.
    # This is a stopgap until address signs become observable entities.
    "name" (auto-percept) (ext-mech obs)
    "struct_parent"
    "parts" (auto-percept)
    "obb"
    # Nav v2: spaces can host openings whose /is_nav_passage gates a
    # macro-graph edge (e.g. an archway between rooms).
    "is_nav_passage"
    # Exterior address-spaces (Section 4.12): the road this space fronts +
    # its street number. A building's `address` points to its address-space;
    # the space's own `address` points to the road. Unset for rooms + wilds.
    "address"
    "address_number"
}
