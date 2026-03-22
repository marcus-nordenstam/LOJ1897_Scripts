# Immobile objects such as buildings
archetype "structure" [512] /obs /alwaysVisible
{
    "isa"           kind                                /kind               /passivePercept
    "date"          date                                /date
     # The name is perceptible or NPCs won't know what building they're in
    "name"          name                                /name               /passivePercept
    
    # ENTITY attrs

    # The SMALLEST spaces each structure is in
    "in"            entity [6] "space"                  /spatialContainment /imperceptible
    "parts"         entity [16] /label "part"           /children           /passivePercept

    # SPATIAL BOUNDS attrs
    "obb"           obb                                 /spatialBounds      /passivePercept
}
