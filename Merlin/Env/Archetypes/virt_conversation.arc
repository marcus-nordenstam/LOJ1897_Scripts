# Meta-entities for conversations
archetype "conversation" [256] /meta
{
    "isa"           kind                                        /kind
    "initiator"     entity "human_player"|"human_npc"                              /passivePercept
    #"participants"  entity "human_player"|"human_npc" [8] /label "participant"     /passivePercept
}
