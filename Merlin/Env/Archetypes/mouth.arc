# One mouth per human: 256
archetype "mouth" [256] /obs
{
    "isa"           kind                                /kind               /passivePercept /unaware
    "struct_parent" entity "human_player"|"human_npc"   /parent             /imperceptible

    # SPATIAL BOUNDS attrs
    "obb"           obb                                 /spatialBounds      /passivePercept
}
