# Interior spaces (Section 4.12): the indoor half of the space split. Rooms,
# halls, entrances, apartments - anything WITHIN a building. Bound by kind: a
# leaf like `kitchen` walks kitchen -> room -> interior_space, hitting this
# archetype before the abstract `space` root. Interior spaces never carry a
# street address (the building does, via its exterior address-space); they may
# carry an apartment_number when a single address holds several apartments.
# cap: ~2000-3000 rooms across ~588 buildings + apartments + a century of
# runtime spawns; the proven room-era value was 4096.
archetype "interior_space" (cap 4096) (per obs) (always-visible) (non-occluder) (sector-coverage)
{
    # Kind-variation identity (see shared/attrs.arc).
    (attr "variant")
    (attr "birth_date")
    # Name is auto-perceived so NPCs know what space they're in.  The ext-mech
    # override (was inherited as imperceptible from common.arc, where names are
    # the human model) lets the visual sensor tag perceived space-name beliefs
    # as OBS, landing them in the OBS pool where confirm/disprove iterates.
    # This is a stopgap until address signs become observable entities.
    (attr "name" (auto-percept) (ext-per obs))
    # The NPC who MADE this space owns it - a hiding_spot cache belongs to its
    # maker. Imperceptible (a concealed cache's ownership is not on show); it gates
    # who searches it (only the owner, via the search_secret_caches act).
    (attr "owner")
    (spatial bounds)
    # Nav v2: spaces can host openings whose /is_nav_passage gates a
    # macro-graph edge (e.g. an archway between rooms).
    (attr "is_nav_passage")
    # An interior space's apartment number, when its building subdivides into
    # numbered apartments (rooms inherit it via their apartment struct_parent).
    (attr "apartment_number")
    # Per-room loose-item index (inverse of each prop's `location`): the props
    # physically in THIS room. Moved here from the building (Section 4.12 per-
    # space model) so weapon / loot / vessel lookups and the confrontation grab
    # are room-scoped (a thief reaches only the room he is in; a defender the
    # whole house). Maintained by hsim set_prop_location.
}
