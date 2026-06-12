# Spaces
# cap: the full St-Revier geography (588 buildings) subdivides into ~2000
# rooms at setup; a century of runtime building spawns (housing market,
# civic fallbacks) needs the headroom above that.
archetype "space" (cap 4096) (mech obs) (always-visible) (non-occluder) (sector-coverage)
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
}
