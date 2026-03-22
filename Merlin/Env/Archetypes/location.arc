# Locations (waypoints, spawnpoints, etc.) for NPC navigation and spawning
archetype "location" [256] /obs /alwaysVisible /nonOccluder
{
    "isa"           kind                                /kind               /passivePercept
    "in"            entity [8] "structure"|"space"      /spatialContainment /imperceptible
    "obb"           obb                                 /spatialBounds      /passivePercept
}
