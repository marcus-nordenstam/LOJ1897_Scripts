# "human" system-capacity times two hands / human: 256 x 2 = 512
archetype "hand" [512] /obs
{
    "isa"           kind                                /kind               /passivePercept /unaware

    # ENTITY attrs

    # parent relationships are imperceptible to reduce the mental burden of perceiving them 
    # (and they are technically redundant since we keep track of parts anyways) 
    # but we keep them in the ECS for efficiency reasons
    "struct_parent" entity "human_player"|"human_npc" /parent             /imperceptible
    "parts"         entity [2] /label "part"            /children           /imperceptible
    "ringFinger"    entity "finger" /label "finger"                         /passivePercept
    "wear"          entity                                                  /passivePercept
    "control"       entity [4]                          /control            /passivePercept

    # SPATIAL BOUNDS attrs
    "obb"           obb                                 /spatialBounds      /passivePercept
}
