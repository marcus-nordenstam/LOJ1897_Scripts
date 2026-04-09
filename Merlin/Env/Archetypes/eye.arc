# One pair of eyes per human: 256
archetype "eye" [256] /obs /nonOccluder
{
    "isa"           kind                                /kind               /passivePercept /unaware
    "struct_parent" entity "human_player"|"human_npc"   /parent             /imperceptible

    # SPATIAL BOUNDS attrs
    "obb"           obb                                 /spatialBounds      /passivePercept
}
