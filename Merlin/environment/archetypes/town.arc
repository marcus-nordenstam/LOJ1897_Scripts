# TOWNS - the widest exterior spaces, and the ones that carry weather.
# A town is a space like any other (see Spaces.mon): a man standing outdoors is IN one,
# and a park or a building sits inside it. What sets it apart is only its size:
# /no_sector_coverage keeps a town-sized box out of the sector grid, which it would
# otherwise tag end to end. The placement resolver walks these populations whole
# instead - they are a handful of entities, not a crowd.
# Like every place, a town is not itself locatable (no (spatial space)): it is placed
# by parent + geometry, and its own parent is the wider space holding it.
archetype "town" (cap 16) (per obs) (always-visible) (non-occluder) (no-sector-coverage)
{
    # Town bounds exist for containment tests but are not auto-perceived
    (spatial bounds)
    # A man knows what town he is standing in. Auto-perceived like every other space
    # name; the ext-mech override lands it in the OBS pool.
    (attr "name" (auto-percept) (ext-per obs))
    (attr "rain")
    (attr "snow")
    (attr "fog")
    (attr "wind")
    (attr "sky")
    # Town atmosphere - non-sentient archetype keeps mood as attrs (Q4).
    (attr "mood-kinds")
    (attr "mood-intensities")
    (attr "mood-set-dates")
}
