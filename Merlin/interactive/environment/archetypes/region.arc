# Top-level world regions with weather state.
# Regions have spatial bounds but are never "in" anything.
# We use /no_sector_coverage to avoid every sector being tagged with a region.
archetype "region" (cap 16) (per obs) (non-occluder) (no-sector-coverage)
{
    # Region bounds exist for containment tests but are not auto-perceived
    (spatial bounds)
    (attr "rain")
    (attr "snow")
    (attr "fog")
    (attr "wind")
    (attr "sky")
    # Region atmosphere - non-sentient archetype keeps mood as attrs (Q4).
    (attr "mood-kinds")
    (attr "mood-intensities")
    (attr "mood-set-dates")
}
