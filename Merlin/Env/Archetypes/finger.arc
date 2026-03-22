# At the moment, we only do the ring-fingers, so finger-capacity == hand-capacity
archetype "finger" [512] /obs
{
    "isa"           kind                                /kind               /passivePercept /unaware

    # ENTITY attrs

    # parent relationships are imperceptible to reduce the mental burden of perceiving them 
    # (and they are technically redundant since we keep track of parts anyways) 
    # but we keep them in the ECS for efficiency reasons
    "parent"        entity "hand"                       /parent             /imperceptible
    "wear"          entity                                                  /passivePercept
    "control"       entity [2]                          /control            /passivePercept

    # SPATIAL BOUNDS attrs
    "obb"           obb                                 /spatialBounds      /passivePercept
}
