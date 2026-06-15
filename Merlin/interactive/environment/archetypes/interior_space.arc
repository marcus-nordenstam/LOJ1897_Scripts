# Interior spaces (Section 4.12): the indoor half of the space split. Rooms,
# halls, entrances, apartments - anything WITHIN a building. Bound by kind: a
# leaf like `kitchen` walks kitchen -> room -> interior_space, hitting this
# archetype before the abstract `space` root. Interior spaces never carry a
# street address (the building does, via its exterior address-space); they may
# carry an apartment_number when a single address holds several apartments.
# cap: ~2000-3000 rooms across ~588 buildings + apartments + a century of
# runtime spawns; the proven room-era value was 4096.
archetype "interior_space" (cap 4096) (mech obs) (always-visible) (non-occluder) (sector-coverage)
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
    # An interior space's apartment number, when its building subdivides into
    # numbered apartments (rooms inherit it via their apartment struct_parent).
    "apartment_number"
}
