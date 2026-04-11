# Medium grid spaces (up to 64 cells) — e.g. a bar counter, large table
archetype "medium_grid_space" [128] /obs /alwaysVisible /nonOccluder /sectorCoverage
{
    "isa"              kind        /kind               /passivePercept
    "date"             date        /date
    "name"             name        /name               /passivePercept

    # ENTITY attrs
    "struct_parent"    entity                           /parent
    "in"               entity [6] "structure" "space"   /spatialContainment /imperceptible
    "contains"         entity [64]                      /contains           /imperceptible

    # SPATIAL BOUNDS attrs
    "obb"              obb                              /spatialBounds      /passivePercept

    # GRID attrs
    "spatial_relation" str                                                  /imperceptible
    "min_cell_level"   int                                                  /imperceptible
    "max_cell_level"   int                                                  /imperceptible
    "cell_occupants"   entity [256]                                         /imperceptible
    "intended_cell_occupants"    entity [256]                               /imperceptible
}
