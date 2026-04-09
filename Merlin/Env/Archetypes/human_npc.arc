# Any human NPC
archetype "human_npc" [256] /obs /raycastVisible /sentient /nonOccluder /inferKindOverride human nonplayer
{
    "eyes"          visual-sensor
    "ears"          sound-sensor
    "muscles"       physical-motors

    # NPCs become aware of their kind and role as part of becoming conscious, since kind never changes, we set this to /unaware
    "isa"           kind                                /kind               /passivePercept /unaware
    "role"          str                                                     /passivePercept /unaware

    # Activity currently being performed (observable by others)
    # We sneakily remap the perceived target & aux to be the kind and place where the activity takes place
    # to avoid generating two separate beliefs for this.
    "perform"       entity "activity"  /lookup_target "isa" /lookup_auxiliary "at"  /passivePercept

    # Age etc
    "date"          date                                /date
    "age"           int                                 /age                /feel
    "ageGroup"      int                                 /ageGroup           /passivePercept

    # Physical features
    "gender"        str                                                     /passivePercept
    "appearance"    str                                                     /passivePercept
    "height"        str                                                     /passivePercept
    "girth"         str                                                     /passivePercept

    # Cultural info
    "name"          name                                /name               
    "nationality"   str                                           

    # Health & condition
    "condition"     str alive                                               /passivePercept
    "pregnantWhen"  date                                                    /passivePercept

    # Physiological states
    "alertness"     str alert                                               /feel

    # Personality
    "sexualOrient"  str                                                     /feel 
    "charisma"      str                                                     /feel 
    "romanticism"   str                                                     /feel 
    "passion"       str                                                     /feel 
    "extroversion"  float                                                   /feel 
    "intelligence"  float                                                   /feel 
    "interests"     str [3]                                                 /feel 

    # ENTITY attrs

    # The list of SMALLEST spaces each entity is inside of
    "in"            entity [8] "structure"|"space" /spatialContainment /imperceptible

    # Which region the NPC is in (updated by Environment, self-perceived via /feel)
    "region"        entity "region"                     /region             /feel

    # This list will expand once we add head, legs, etc.  For now, just hands.
    # NOTE that parts is imperceptible since we instead perceive specific body-parts below:
    "parts"         entity "hand"|"eye"|"mouth" [4] /label "part"          /children           /imperceptible

    # Hands are so integral to reasoning that we give them their own attr (even though they
    # also appear in the parts attr).
    "leftHand"      entity "hand"  /label "hand"                            /passivePercept
    "rightHand"     entity "hand"  /label "hand"                            /passivePercept

    # Eyes
    "eyes"          entity "eye"  /label "eyes"                            /passivePercept

    # Mouth
    "mouth"         entity "mouth" /label "mouth"                           /passivePercept

    # This is used to keep conversations in sync among NPCs, and also allow anyone close enough
    # to observe the involved parties to infer that they're in a conversation
    "conversation"  entity "conversation"                                           /passivePercept

    # This is only used to pass on the appropriate DNA from the father.
    "pregnantBy"    entity

    # Items controlled by this NPC (stowed or held)
    "control"       entity [4]                          /control            /passivePercept

    # SPATIAL BOUNDS attrs
    "obb"           obb                                 /spatialBounds      /passivePercept
}
