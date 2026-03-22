# One pair of eyes per human: 256
archetype "eye" [256] /obs
{
    "isa"           kind                                /kind               /passivePercept /unaware
    "parent"        entity "human_player"|"human_npc" /parent             /imperceptible

    # SPATIAL BOUNDS attrs
    "obb"           obb                                 /spatialBounds      /passivePercept
}
