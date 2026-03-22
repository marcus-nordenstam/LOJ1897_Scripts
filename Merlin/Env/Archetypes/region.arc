# Top-level world regions with weather state.
# Regions have spatial bounds but are never "in" anything.
# Weather attrs are passively perceived by NPCs in the region.
archetype "region" [16] /obs /nonOccluder
{
    "isa"           kind            /kind
    "obb"           obb             /spatialBounds      /imperceptible
    "rain"          str heavy       /obs /passivePercept
    "snow"          str none        /obs /passivePercept
    "fog"           str none        /obs /passivePercept
    "wind"          str none        /obs /passivePercept
    "sky"           str clear       /obs /passivePercept
}
