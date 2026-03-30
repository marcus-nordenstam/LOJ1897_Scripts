# Any sound - including speech
archetype "sound" [256] /nonOccluder /hear
{
    "isa"           kind                                /kind               /passivePercept

    # This holds the specific action that produced this sound.
    # For example {john TELL (msg...) sam}, or {john ASK (qs...) sam}.
    # We tag it as imperceptible because we don't want to perceive it as embedded in the sound:
    #    {sound createAction {john TELL (msg...) sam}}
    # but rather we want to preceive the createAction on it's own.
    "createAction"  pattern                             /createAction       /imperceptible

    # ENTITY attrs

    # The list of SMALLEST spaces each entity is inside of
    "in"            entity [6] "space"                  /spatialContainment /imperceptible
    "speaker"       entity "human_player"|"human_npc"   /speaker            /imperceptible
    "preroll"       float                               /preroll             /imperceptible

    # SPATIAL BOUNDS attrs
    "obb"           obb                                 /spatialBounds      /passivePercept
}
