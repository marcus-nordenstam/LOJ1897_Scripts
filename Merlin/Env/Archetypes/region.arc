# Top-level world regions with weather state.
# Regions have spatial bounds but are never "in" anything.
# We use /noSectorCoverage to avoid every sector being tagged with a region.
archetype "region" [16] /obs /nonOccluder /noSectorCoverage
{
    # Region bounds exist for containment tests but are not auto-perceived
    "obb" /no-auto-percept
    "rain"
    "snow"
    "fog"
    "wind"
    "sky"
}
