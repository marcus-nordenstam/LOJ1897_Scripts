# Spaces
archetype "space" [2096] /obs /alwaysVisible /nonOccluder /sectorCoverage
{
    "isa"           kind                                /kind               /passivePercept
    "date"          date                                /date
    # The name is perceptible or NPCs won't know what space they're in.
    "name"          name                                /name               /passivePercept
   
    # ENTITY attrs

    # parent relationships are imperceptible to reduce the mental burden of perceiving them 
    # (and they are technically redundant since we keep track of parts) 
    # but we keep them in the ECS for efficiency reasons
    "parent"        entity                              /parent
    "parts"         entity [6] /label "part"            /children           /passivePercept
    # The SMALLEST spaces and structures each space is in
    "in"            entity [6] "structure" "space"      /spatialContainment /imperceptible

    # SPATIAL BOUNDS attrs
    "obb"           obb                                 /spatialBounds      /passivePercept
}
