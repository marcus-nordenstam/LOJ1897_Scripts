# Common attr definitions — shared across archetypes.
# Each attr name is defined exactly once here. Archetypes reference them by name.
# Every attr MUST declare an explicit transmission mechanism: /obs, /feel, /hear, /read, /imperceptible
# Use /state-flags-tar, /state-flags-sub, /state-flags-aux for per-field @-flags (pipe-separated).

# Identity & metadata
# NOTE: "isa" (kind attr) is auto-created on every population — no need to declare it.
attr "date"             date                                    /date       /imperceptible
# Name attr. /auto-percept can be added per-archetype for entities whose name matters (spaces, structures).
attr "name"             name                                    /name       /obs

# Spatial
attr "obb"              obb                                     /spatialBounds  /obs /auto-percept /state-flags-tar @excl
attr "spatial_relation" str                                                 /obs /auto-percept
# Parent relationships are kept in the ECS for efficiency (technically redundant with parts)
attr "struct_parent"    entity "structure"|"part"|"space"|"hand"|"human_player"|"human_npc"    /parent /obs /state-flags-tar @excl
attr "parts"            entity [] /state "part"                 /children   /obs
# The SMALLEST spaces and structures each entity is inside of
attr "in"               entity [4] "structure"|"space"          /spatialContainment /imperceptible
# Reverse of "in": all entities spatially contained within this entity
attr "contains"         entity []                               /contains   /imperceptible

# Ownership & control
# The entity currently controlling the position of this entity (if any)
attr "controlledBy"     entity                                  /controlledBy   /imperceptible
# What this entity controls (stowed or held items)
attr "control"          entity []                               /control    /obs /auto-percept
# Which stack this entity is in, if any. If not in a stack, set to @nothing.
attr "inStack"          entity "stack"                          /inStack    /obs

# Conditions & properties
attr "condition"        str alive                                           /obs /auto-percept /state-flags-tar @excl
attr "color"            str                                                 /obs /auto-percept /state-flags-tar @excl

# Sensors & motors
attr "visual-sensor"    visual-sensor
attr "sound-sensor"     sound-sensor
attr "physical-motors"  physical-motors

# Body structure
# Hands are integral to reasoning — they get their own attrs even though they also appear in parts
attr "leftHand"         entity "hand" /state "hand"                         /obs /auto-percept
attr "rightHand"        entity "hand" /state "hand"                         /obs /auto-percept
attr "eyes"             entity "eye" /state "eyes"                          /obs /auto-percept
attr "mouth"            entity "mouth" /state "mouth"                       /obs /auto-percept
attr "ringFinger"       entity "finger" /state "finger"                     /obs /auto-percept
attr "wear"             entity                                              /obs /auto-percept

# Demographics
attr "role"             str                                                 /obs /auto-percept /unaware /state-flags-tar @excl
attr "age"              int                                     /age        /feel /state-flags-tar @excl
attr "ageGroup"         int                                     /ageGroup   /obs /auto-percept /state-flags-tar @excl
attr "gender"           str                                                 /obs /auto-percept /state-flags-tar @excl
attr "appearance"       str                                                 /obs /auto-percept /state-flags-tar @excl
attr "height"           str                                                 /obs /auto-percept /state-flags-tar @excl
attr "girth"            str                                                 /obs /auto-percept /state-flags-tar @excl
attr "nationality"      str                                                 /obs /state-flags-tar @excl

# Personality & internal
attr "alertness"        str alert                                           /feel /state-flags-tar @excl
attr "sexualOrient"     str                                                 /feel /state-flags-tar @excl
attr "charisma"         str                                                 /feel /state-flags-tar @excl
attr "romanticism"      str                                                 /feel /state-flags-tar @excl
attr "passion"          str                                                 /feel /state-flags-tar @excl
attr "extroversion"     float                                               /feel /state-flags-tar @excl
attr "intelligence"     float                                               /feel /state-flags-tar @excl
attr "interests"        str [3]                                             /feel

# Relationships
# Keeps conversations in sync among NPCs; allows nearby observers to infer a conversation
attr "conversation"     entity "conversation"                               /obs /auto-percept /state-flags-tar @excl
attr "pregnantWhen"     date                                                /obs /auto-percept
# Only used to pass on appropriate DNA from the father
attr "pregnantBy"       entity                                              /imperceptible

# Region — updated by Environment, self-perceived via /feel
attr "region"           entity "region"                         /region     /feel /state-flags-tar @excl

# Activity — remaps perceived target & aux to kind and place of the activity
attr "perform"          entity "activity" /lookup_target "isa" /lookup_auxiliary "at"  /obs /auto-percept

# Sound
# Holds the specific action that produced this sound (e.g. {john TELL (msg...) sam}).
# Imperceptible so we perceive the createAction on its own, not embedded in the sound.
attr "createAction"     pattern                                 /createAction   /imperceptible
attr "speaker"          entity "human_player"|"human_npc"       /speaker    /imperceptible
attr "preroll"          float                                   /preroll    /imperceptible

# Prop-specific
# Writings are expressed as a Merlin pattern holding a list of messages in sections.
# e.g. (msg [ [[k title] {book title foo} {book by bar}] [[k chapter] ...]])
attr "writings"         pattern                                             /read /state-flags-tar @msg @S
# How hard the entity is being gripped. 0=loose, 1=hard
attr "controlForce"     int                                                 /imperceptible

# Stack
attr "stackLabel"       str                                                 /obs /auto-percept /state-flags-tar @excl
attr "items"            entity [16]                                         /obs
attr "top"              entity                                              /obs /state-flags-tar @excl

# Weather (region)
attr "rain"             str heavy                                           /obs /auto-percept /state-flags-tar @excl
attr "snow"             str none                                            /obs /auto-percept /state-flags-tar @excl
attr "fog"              str none                                            /obs /auto-percept /state-flags-tar @excl
attr "wind"             str none                                            /obs /auto-percept /state-flags-tar @excl
attr "sky"              str clear                                           /obs /auto-percept /state-flags-tar @excl

# Conversation
attr "initiator"        entity "human_player"|"human_npc"                   /obs /auto-percept

# Fluid
attr "fluid_amount"     float                                               /obs /auto-percept /state-flags-tar @excl

# Transaction
attr "at"               entity "structure"|"space"                          /obs /auto-percept

# Instance
attr "prototype"        entity                                              /prototype  /imperceptible
