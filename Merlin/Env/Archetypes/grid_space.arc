# Grid spaces — OBB subdivided into a regular grid of cells for spatial availability queries
archetype "grid_space" [256] /obs /alwaysVisible /nonOccluder /sectorCoverage
{
    "isa"              kind        /kind               /passivePercept
    "date"             date        /date
    "name"             name        /name               /passivePercept
    "spatial_relation" str                             /passivePercept

    # ENTITY attrs
    "struct_parent"    entity                           /parent
    "in"               entity [6] "structure" "space"   /spatialContainment /imperceptible
    "contains"         entity []                        /contains           /imperceptible

    # SPATIAL BOUNDS attrs
    "obb"              obb                              /spatialBounds      /passivePercept

    # GRID attrs
    "min_cell_level"   int                                                  /imperceptible
    "max_cell_level"   int                                                  /imperceptible
    "cell_occupants"   entity []                                            /imperceptible
    "intended_cell_occupants"    entity []                                  /imperceptible
}
