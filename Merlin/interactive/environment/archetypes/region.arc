# Top-level world regions with weather state.
# Regions have spatial bounds but are never "in" anything.
# We use /no_sector_coverage to avoid every sector being tagged with a region.
archetype "region" (cap 16) (mech obs) (non-occluder) (no-sector-coverage)
{
    # Region bounds exist for containment tests but are not auto-perceived
    "obb" (no-auto-percept)
    "rain"
    "snow"
    "fog"
    "wind"
    "sky"
    # Region atmosphere - non-sentient archetype keeps mood as attrs (Q4).
    "mood_kinds"
    "mood_intensities"
    "mood_set_dates"
}
