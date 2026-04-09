# Any human PLAYER
archetype "human_player" [256] /obs /raycastVisible /player /nonOccluder /inferKindOverride human player
{
    # Required for performing physical actions in the world
    "muscles"       physical-motors

    # Kind
    "isa"           kind                                /kind               /passivePercept

    # Role
    "role"          str                                                     /passivePercept

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

    # ENTITY attrs

    # The list of SMALLEST spaces each entity is inside of
    "in"            entity [8] "structure"|"space" /spatialContainment /imperceptible

    # Which region the player is in (updated by Environment, self-perceived via /feel)
    "region"        entity "region"                     /region             /feel

    # NOTE that parts is imperceptible since we instead perceive specific body-parts below:
    "parts"         entity "hand"|"eye"|"mouth" [4] /label "part"                 /children           /imperceptible

    # Hands are so integral to reasoning that we give them their own attr (even though they
    # also appear in the parts attr).
    "leftHand"      entity "hand"  /label "hand"                            /passivePercept
    "rightHand"     entity "hand"  /label "hand"                            /passivePercept

    # Eyes
    "eyes"          entity "eye"   /label "eyes"                            /passivePercept

    # Mouth
    "mouth"         entity "mouth" /label "mouth"                           /passivePercept

    # This is used to keep conversations in sync among NPCs, and also allow anyone close enough
    # to observe the involved parties to infer that they're in a conversation
    "conversation"  entity "conversation"                                           /passivePercept

    # This is only used to pass on the appropriate DNA from the father.
    "pregnantBy"    entity

    # Items controlled by this player (stowed or held)
    "control"       entity [4]                          /control            /passivePercept

    # SPATIAL BOUNDS attrs
    "obb"           obb                                 /spatialBounds      /passivePercept
}
