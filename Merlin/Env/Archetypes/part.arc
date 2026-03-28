# This can be a part of a structure OR a prop
archetype "part" [2048] /obs
{
    "isa"           kind                                /kind               /passivePercept
    "date"          date                                /date
    "name"          name                                /name               /passivePercept

    # ENTITY attrs

    # parent relationships are imperceptible to reduce the mental burden of perceiving them 
    # (and they are technically redundant since we keep track of parts) 
    # but we keep them in the ECS for efficiency reasons
    "struct_parent" entity "structure" | "part"         /parent
    "parts"         entity [4] /label "part"            /children           /passivePercept

    # SPATIAL BOUNDS attrs
    "obb"           obb                                 /spatialBounds      /passivePercept
}
