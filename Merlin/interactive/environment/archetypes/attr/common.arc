# Common attr definitions — shared across archetypes.
# Each attr name is defined exactly once here. Archetypes reference them by name.
# Every attr MUST declare an explicit transmission mechanism: /obs, /feel, /hear, /read, /imperceptible
# Use /state_flags_tar, /state_flags_sub, /state_flags_aux for per-field @-flags (pipe-separated).

# Identity & metadata

# NOTE: "isa" (kind attr) is auto-created on every population — no need to declare it.

# Lifecycle dates (used by historical sim; persist into interactive).
attr "birth_date"       date                                    /date                  /feel
attr "death_date"       date                                    /state_flags_tar @excl /imperceptible
attr "death_cause"      kind                                                           /imperceptible

# Name attr. /auto_percept can be added per-archetype for entities whose name matters (spaces, structures).
attr "name"             name                                    /name       /obs

# Spatial
attr "obb"              obb                                     /spatial_bounds  /obs /auto_percept /state_flags_tar @excl
# Parent relationships are kept in the ECS for efficiency (technically redundant with parts)
attr "struct_parent"    entity "structure"|"container_structure"|"structure_part"|"part"|"space"|"hand"|"human_player"|"human_npc"    /parent /obs /state_flags_tar @excl
attr "parts"            entity [12] /state "part"               /children   /obs

# Ownership & control
# The entity currently controlling the position of this entity (if any)
attr "controlled_by"    entity                                  /controlled_by   /imperceptible
# What this entity controls (stowed or held items)
attr "control"          entity [12]                             /control    /obs /auto_percept
# Which stack this entity is in, if any. If not in a stack, set to _.
attr "in_stack"         entity "stack"                          /in_stack    /obs

# Conditions & properties. Conceptual: kind-typed; @excl lives on the concept.
attr "condition"        kind alive                                          /obs /auto_percept
attr "color"            kind                                                /obs /auto_percept

# Sensors & motors
attr "visual_sensor"    visual-sensor
attr "sound_sensor"     sound-sensor
attr "physical_motors"  physical-motors

# Body structure
# Hands are integral to reasoning — they get their own attrs even though they also appear in parts
attr "left_hand"        entity "hand" /state "hand"                         /obs /auto_percept
attr "right_hand"       entity "hand" /state "hand"                         /obs /auto_percept
attr "head"             entity "head" /state "head"                         /obs /auto_percept
attr "eyes"             entity "eye" /state "eyes"                          /obs /auto_percept
attr "mouth"            entity "mouth" /state "mouth"                       /obs /auto_percept
attr "ring_finger"      entity "finger" /state "finger"                     /obs /auto_percept
attr "wear"             entity                                              /obs /auto_percept

# Demographics
attr "role"             kind                                                /obs /auto_percept /unaware
attr "age"              int                                     /age        /feel /state_flags_tar @excl
attr "age_group"        int                                     /age_group  /obs /auto_percept /state_flags_tar @excl
# gender / appearance / height / girth are conceptual: kind-typed, value is an
# ontology term. @excl now lives on the concept in Concepts.mon (rule 4b / 5).
attr "gender"           kind                                                /obs /auto_percept
attr "appearance"       kind                                                /obs /auto_percept
attr "height"           kind                                                /obs /auto_percept
attr "girth"            kind                                                /obs /auto_percept
# nationality and social standing are not physical environment state - they
# exist solely as beliefs (nationality / class_situation labels in States.mon).

# Personality & internal. alertness / sexual_orient are kind-typed; @excl
# lives on the concept in Concepts.mon. Interests are NOT physical - they
# are seeded directly as {@self interest <kind>} self-beliefs in
# mx_make_human (kinds sampled from the `interest` subtree in Concepts.mon)
# and propagated via the friend-tier belief mirror.
attr "alertness"        kind alert                                          /feel
attr "sexual_orient"    kind                                                /feel

# Accumulated intoxication, 0..1 - the get-drunk seed event bumps it; the F3.7
# sobriety classifier reads it (see hsim_derive.cc).
attr "intoxication"     float                                               /obs /feel /state_flags_tar @excl

# Big Five personality - the ten aspects of the Big Five Aspect Scale
# (DeYoung/Quilty/Peterson 2007), two per OCEAN domain. Genetic and heritable
# (gaussian + mid-parent blend in mx_make_human), self-known via /feel. Each
# is a 0..1 float, population mean 0.5. Mirrored as {@self <aspect> <f>}
# self-beliefs; the appraisal pipeline, mood and the F3 classifiers read them.
attr "openness"         float                                               /feel /state_flags_tar @excl
attr "intellect"        float                                               /feel /state_flags_tar @excl
attr "industriousness"  float                                               /feel /state_flags_tar @excl
attr "orderliness"      float                                               /feel /state_flags_tar @excl
attr "enthusiasm"       float                                               /feel /state_flags_tar @excl
attr "assertiveness"    float                                               /feel /state_flags_tar @excl
attr "compassion"       float                                               /feel /state_flags_tar @excl
attr "politeness"       float                                               /feel /state_flags_tar @excl
attr "volatility"       float                                               /feel /state_flags_tar @excl
attr "withdrawal"       float                                               /feel /state_flags_tar @excl

# Dark-tetrad personality - a separate four-trait malevolence overlay on the
# Big Five. Same 0..1 float scale and gaussian/heritable synthesis, but never
# mirrored across the boundary (believe_about Band 5) - an NPC's malevolence
# stays secret. Drives crime motives (Phase 10).
attr "narcissism"       float                                               /feel /state_flags_tar @excl
attr "machiavellianism" float                                               /feel /state_flags_tar @excl
attr "psychopathy"      float                                               /feel /state_flags_tar @excl
attr "sadism"           float                                               /feel /state_flags_tar @excl

# Relationships
attr "pregnant_when"    date                                                /obs /auto_percept
# Only used to pass on appropriate DNA from the father
attr "pregnant_by"      entity                                              /imperceptible

# Region — updated by Environment, self-perceived via /feel
attr "region"           entity "region"                         /region     /feel /state_flags_tar @excl

# Activity — remaps perceived target & aux to kind and place of the activity
attr "perform"          entity "activity" /lookup_target "isa" /lookup_auxiliary "at"  /obs /auto_percept

# Sound
# Holds the specific action that produced this sound (e.g. {john TELL (msg...) sam}).
# Imperceptible so we perceive the createAction on its own, not embedded in the sound.
attr "create_action"    pattern                                 /create_action   /imperceptible
attr "speaker"          entity "human_player"|"human_npc"       /speaker    /imperceptible
attr "preroll"          float                                   /preroll    /imperceptible

# Prop-specific
# A writing is a Merlin pattern holding a document's content - a (msg ...)
# wrapper around one or more belief sentences. /read transmits it to a
# reader's mind, where the sentences are evaluated into beliefs.
attr "writing"          pattern                                             /read /state_flags_tar @msg @S
# How hard the entity is being gripped. 0=loose, 1=hard
attr "control_force"    int                                                 /imperceptible

# Stack
attr "stack_label"      str                                                 /obs /auto_percept /state_flags_tar @excl
attr "items"            entity [16]                                         /obs
attr "top"              entity                                              /obs /state_flags_tar @excl

# Weather (region)
attr "rain"             kind heavy                                          /obs /auto_percept
attr "snow"             kind none                                           /obs /auto_percept
attr "fog"              kind none                                           /obs /auto_percept
attr "wind"             kind none                                           /obs /auto_percept
attr "sky"              kind clear                                          /obs /auto_percept

# Region mood - non-sentient archetype, so per Q4 we keep mood state on the
# region itself as parallel-array attrs. Updated by run_region_mood_pass.
attr "mood_kinds"        kind [8]  /state "mood"                             /obs /auto_percept
attr "mood_intensities"  int  [8]                                            /obs
attr "mood_set_dates"    date [8]                                            /imperceptible

# Building physical / structural properties.
attr "isolated"         int                                                 /obs
attr "has_crypt"        int                                                 /obs
attr "locked_wing"      int                                                 /obs
# Era bounds - the building physically exists from era_min to era_max.
attr "era_min"          date                                                /imperceptible
attr "era_max"          date                                                /imperceptible
# Address: entity ref to the road the building is on, OR to the estate
# entity itself when there's no street (estate-on-grounds case). Combined
# with address_number ("14 Victoria Street", or "Blackthorne Estate" with
# _ number).
attr "address"          entity "road"|"structure"|"container_structure"     /obs /auto_percept
attr "address_number"   int                                                 /obs /auto_percept

# Conversation
attr "initiator"        entity "human_player"|"human_npc"                   /obs /auto_percept

# Fluid
attr "fluid_amount"     float                                               /obs /auto_percept /state_flags_tar @excl

# Transaction
attr "at"               entity "structure"|"container_structure"|"space"   /obs /auto_percept

# Instance
attr "prototype"        entity                                              /prototype  /imperceptible

# Navigation v2 (see Merlin/Docs/nav_v2_plan.md)
# /is_nav_passage — runtime gate: 1 = passable, 0 = dormant. Action handlers
#   flip this on the opening entity (door/gate/large_window). nav_graph
#   subscribes and toggles the corresponding macro-graph passage edge.
# /nav_mesh — Hstr cache key for the structure's baked nav-mesh data;
#   written by Player at scene load when an island is registered.
# Throat geometry, opening identity and binding are all derived at scene-
# load from the opening Merlin entity's own TransformComponent (position,
# rotation, scale-as-half-extents per mx_radii_from_world_scale) plus its
# spatial relationship to nearby nav-meshes. No /opening_name attr; no
# /passage_throat_obb attr.
attr "is_nav_passage"   int                                              /is_nav_passage  /obs
attr "nav_mesh"         str                                              /nav_mesh  /imperceptible
# /blocks_nav_terrain — when 1, the entity's OBB footprint rasterises as a
# terrain-walkability blocker during t_nav_terrain::build (nav_v2_plan.md §7).
# Defaults to 0 on plain `structure`; archetypes that physically obstruct the
# ground (buildings, walls, fences, gates, large rocks, tree trunks) override
# to 1 in their own .arc file. Connector throat clearing (§7.3) overrides
# this for cells under a structure's door, so a building with /blocks_nav_terrain
# = 1 still allows path entry through its baked-passage doorway.
attr "blocks_nav_terrain"  int                                           /blocks_nav_terrain  /imperceptible

# Navigation v2 Phase 3 - road spline geometry.
# Per-entity authored road geometry: up to 16 centripetal Catmull-Rom CVs,
# width in metres, auto-junction radius (default 1.0m), and flags. The CVs
# come from the GrymEngine SplineComponent + RoadComponent the artist
# placed; Game.cc's LoadScene bridge reads them and calls
# mx_write_spline_attr per road entity. Junctions are auto-derived at
# scene load by Environment::resolve_road_network clustering endpoints;
# no junction archetype, no /junction attr.
# See Merlin/Docs/road_network_plan.md.
attr "spline_geometry"   spline                                           /spline_geometry  /imperceptible
