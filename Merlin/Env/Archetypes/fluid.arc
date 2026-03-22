# Fluids (beer, water, etc.) — observable, can be controlled by a container
archetype "fluid" [256] /obs
{
    "isa"           kind                                /kind               /passivePercept
    "controlledBy"  entity                              /controlledBy
    "fluid_amount"  float                                                   /passivePercept
    "obb"           obb                                 /spatialBounds      /passivePercept
    "in"            entity [8] "structure"|"space"      /spatialContainment /imperceptible
}
