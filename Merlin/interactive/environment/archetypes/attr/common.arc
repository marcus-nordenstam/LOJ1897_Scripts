# Common attr definitions - shared across archetypes.
# Each attr name is defined exactly once here. Archetypes reference them by name.
# Every attr MUST declare an explicit transmission mechanism: /obs, /feel, /hear, /read, /imperceptible
# Use /state_flags_tar, /state_flags_sub, /state_flags_aux for per-field @-flags (pipe-separated).

# Identity & metadata

# NOTE: "isa" (kind attr) is auto-created on every population - no need to declare it.

# Lifecycle dates (used by historical sim; persist into interactive).
attr "birth_date" (type date) (spec-attr date) (mech feel)
attr "death_date" (type date) (state-flags-tar @excl) (imperceptible)
attr "death_cause" (type kind) (imperceptible)

# Name attr. For humans: cognitively KNOWN, not felt (you don't sense your
# name as a body feeling - you reason about it); externally imperceptible (you
# can't tell a stranger's name by looking at them). Beliefs land in the
# REASON pool, no perception loop confirms or disproves them, so the name
# persists as long as the holder keeps the belief. Structure-style entities
# (buildings, roads) override (ext-mech obs) per-archetype because their names
# WILL eventually be observable via address signs - for now those archetypes
# also add (auto-percept).
attr "name" (type name) (spec-attr name) (int-mech reason) (ext-mech imperceptible)

# Spatial
attr "obb" (type obb) (spec-attr spatial-bounds) (mech obs) (auto-percept) (state-flags-tar @excl)
# Parent relationships are kept in the ECS for efficiency (technically redundant with parts)
attr "struct_parent" (type entity) (entity "structure" "container_structure" "structure_part" "part" "space" "hand" "human_player" "human_npc") (spec-attr parent) (mech obs) (state-flags-tar @excl)
attr "parts" (type entity array 12) (state "part") (spec-attr children) (int-mech feel) (ext-mech obs)

# Ownership & control
# The entity currently controlling the position of this entity (if any)
attr "controlled_by" (type entity) (spec-attr controlled-by) (imperceptible)
# What this entity controls (stowed or held items)
attr "control" (type entity array 12) (spec-attr control) (mech obs) (auto-percept)
# Which stack this entity is in, if any. If not in a stack, set to _.
attr "in_stack" (type entity) (entity "stack") (spec-attr in-stack) (mech obs)

# Conditions & properties. Conceptual: kind-typed; @excl lives on the concept.
attr "condition" (type kind alive) (mech obs) (auto-percept)
attr "color" (type kind) (mech obs) (auto-percept)

# Sensors & motors
attr "visual_sensor" (type visual-sensor)
attr "sound_sensor" (type sound-sensor)
attr "physical_motors" (type physical-motors)

# Body structure
# Hands are integral to reasoning - they get their own attrs even though they also appear in parts.
# Body parts are FELT internally (the NPC always knows their own body) AND observed externally
# (others see your hands when they look at you). Same int-feel-ext-obs split as `name`.
attr "left_hand" (type entity) (entity "hand") (state "hand") (int-mech feel) (ext-mech obs) (auto-percept)
attr "right_hand" (type entity) (entity "hand") (state "hand") (int-mech feel) (ext-mech obs) (auto-percept)
attr "head" (type entity) (entity "head") (state "head") (int-mech feel) (ext-mech obs) (auto-percept)
attr "eyes" (type entity) (entity "eye") (state "eyes") (int-mech feel) (ext-mech obs) (auto-percept)
attr "mouth" (type entity) (entity "mouth") (state "mouth") (int-mech feel) (ext-mech obs) (auto-percept)
attr "ring_finger" (type entity) (entity "finger") (state "finger") (int-mech feel) (ext-mech obs) (auto-percept)
# PR-evi-A 2026-05-25 - the central body. Same int-feel-ext-obs split as
# head / hand / mouth. The default wound-site when a perpetration method
# row omits :wound-site.
attr "torso" (type entity) (entity "torso") (state "torso") (int-mech feel) (ext-mech obs) (auto-percept)
attr "wear" (type entity) (mech obs) (auto-percept)

# Demographics
attr "game_role" (type kind) (mech obs) (auto-percept) (unaware)
attr "age" (type int) (range 0 120) (spec-attr age) (mech feel) (state-flags-tar @excl)
attr "age_group" (type int) (range 0 8) (spec-attr age-group) (mech obs) (auto-percept) (state-flags-tar @excl)
# gender / appearance / height / girth are conceptual: kind-typed, value is an
# ontology term. @excl now lives on the concept in Concepts.mon (rule 4b / 5).
attr "gender" (type kind) (mech obs) (auto-percept)
attr "appearance" (type kind) (mech obs) (auto-percept)
attr "height" (type kind) (mech obs) (auto-percept)
attr "girth" (type kind) (mech obs) (auto-percept)
# nationality and social standing are not physical environment state - they
# exist solely as beliefs (nationality / class_situation labels in States.mon).

# Personality & internal. alertness / sexual_orient are kind-typed; @excl
# lives on the concept in Concepts.mon. Interests are NOT physical - they
# are seeded directly as {@self interest <kind>} self-beliefs in
# mx_make_human (kinds sampled from the `interest` subtree in Concepts.mon)
# and propagated via the friend-tier belief mirror.
attr "alertness" (type kind alert) (mech feel)
attr "sexual_orient" (type kind) (mech feel)

# Accumulated intoxication, 0..1 - the get-drunk seed event bumps it; the F3.7
# sobriety classifier reads it (see hsim_derive.cc).
attr "intoxication" (type float) (range 0 1) (mech obs) (mech feel) (state-flags-tar @excl)

# Big Five personality - the ten aspects of the Big Five Aspect Scale
# (DeYoung/Quilty/Peterson 2007), two per OCEAN domain. Genetic and heritable
# (gaussian + mid-parent blend in mx_make_human), self-known via /feel. Each
# is a 0..1 float, population mean 0.5. Mirrored as {@self <aspect> <f>}
# self-beliefs; the appraisal pipeline, mood and the F3 classifiers read them.
attr "openness"        (type float) (range 0 1) (mech feel) (state-flags-tar @excl)
attr "intellect"       (type float) (range 0 1) (mech feel) (state-flags-tar @excl)
attr "industriousness" (type float) (range 0 1) (mech feel) (state-flags-tar @excl)
attr "orderliness"     (type float) (range 0 1) (mech feel) (state-flags-tar @excl)
attr "enthusiasm"      (type float) (range 0 1) (mech feel) (state-flags-tar @excl)
attr "assertiveness"   (type float) (range 0 1) (mech feel) (state-flags-tar @excl)
attr "compassion"      (type float) (range 0 1) (mech feel) (state-flags-tar @excl)
attr "politeness"      (type float) (range 0 1) (mech feel) (state-flags-tar @excl)
attr "volatility"      (type float) (range 0 1) (mech feel) (state-flags-tar @excl)
attr "withdrawal"      (type float) (range 0 1) (mech feel) (state-flags-tar @excl)

# Dark-tetrad personality - a separate four-trait malevolence overlay on the
# Big Five. Same 0..1 float scale and gaussian/heritable synthesis, but never
# mirrored across the boundary (believe_about Band 5) - an NPC's malevolence
# stays secret. Drives crime motives (Phase 10).
attr "narcissism"       (type float) (range 0 1) (mech feel) (state-flags-tar @excl)
attr "machiavellianism" (type float) (range 0 1) (mech feel) (state-flags-tar @excl)
attr "psychopathy"      (type float) (range 0 1) (mech feel) (state-flags-tar @excl)
attr "sadism"           (type float) (range 0 1) (mech feel) (state-flags-tar @excl)

# Physical traits (PR-3b 2026-05-25). 0..1 floats with population mean 0.5,
# parallel shape to the Big Five aspects. Genetic + heritable (mid-parent
# gaussian, to be wired in mx_make_human alongside the existing personality
# synthesis); age-decay over the lifespan lands in a follow-up. Both /feel
# (the NPC's own body-awareness) and /obs (others observe build, gait,
# stamina from outward signs). Read by perpetration.hsc method rows via
# (attr ?actor <trait>) gates - strength for bludgeon/strangle, dexterity
# for stab/garrotte (hand-and-finger precision), agility for climb/evade
# (whole-body acrobatics), endurance for pursuit/sustained fights.
attr "strength"   (type float) (range 0 1) (mech feel) (mech obs) (state-flags-tar @excl)
attr "dexterity"  (type float) (range 0 1) (mech feel) (mech obs) (state-flags-tar @excl)
attr "agility"    (type float) (range 0 1) (mech feel) (mech obs) (state-flags-tar @excl)
attr "endurance"  (type float) (range 0 1) (mech feel) (state-flags-tar @excl)

# Relationships
attr "pregnant_when" (type date) (mech obs) (auto-percept)
# Only used to pass on appropriate DNA from the father
attr "pregnant_by" (type entity) (imperceptible)

# Region - updated by Environment, self-perceived via /feel
attr "region" (type entity) (entity "region") (spec-attr region) (mech feel) (state-flags-tar @excl)

# Activity - remaps perceived target & aux to kind and place of the activity
attr "perform" (type entity) (entity "activity") (lookup-target "isa") (lookup-aux "at") (mech obs) (auto-percept)

# Sound
# Holds the specific action that produced this sound (e.g. {john TELL (msg...) sam}).
# Imperceptible so we perceive the createAction on its own, not embedded in the sound.
attr "create_action" (type pattern) (spec-attr create-action) (imperceptible)
attr "speaker" (type entity) (entity "human_player" "human_npc") (spec-attr speaker) (imperceptible)
attr "preroll" (type float) (range 0 10) (spec-attr preroll) (imperceptible)

# Prop-specific
# A writing is a Merlin pattern holding a document's content - a (msg ...)
# wrapper around one or more belief sentences. /read transmits it to a
# reader's mind, where the sentences are evaluated into beliefs.
attr "writing" (type pattern) (mech read) (state-flags-tar @msg @S)
# How hard the entity is being gripped. 0=loose, 1=hard
attr "control_force" (type int) (range 0 1) (imperceptible)

# Stack
attr "stack_label" (type str) (mech obs) (auto-percept) (state-flags-tar @excl)
attr "items" (type entity array 16) (mech obs)
attr "top" (type entity) (mech obs) (state-flags-tar @excl)

# Weather (region)
attr "rain" (type kind heavy) (mech obs) (auto-percept)
attr "snow" (type kind none) (mech obs) (auto-percept)
attr "fog" (type kind none) (mech obs) (auto-percept)
attr "wind" (type kind none) (mech obs) (auto-percept)
attr "sky" (type kind clear) (mech obs) (auto-percept)

# Region mood - non-sentient archetype, so per Q4 we keep mood state on the
# region itself as parallel-array attrs. Updated by run_region_mood_pass.
attr "mood_kinds" (type kind array 8) (state "mood") (mech obs) (auto-percept)
attr "mood_intensities" (type int array 8) (range 0 100) (mech obs)
attr "mood_set_dates" (type date array 8) (imperceptible)

# Building physical / structural properties.
attr "isolated"    (type int) (range 0 1) (mech obs)
attr "has_crypt"   (type int) (range 0 1) (mech obs)
attr "locked_wing" (type int) (range 0 1) (mech obs)
# Era bounds - the building physically exists from era_min to era_max.
attr "era_min" (type date) (imperceptible)
attr "era_max" (type date) (imperceptible)
# Address: entity ref to the road the building is on, OR to the estate
# entity itself when there's no street (estate-on-grounds case). Combined
# with address_number ("14 Victoria Street", or "Blackthorne Estate" with
# _ number).
attr "address" (type entity) (entity "road" "structure" "container_structure") (mech obs) (auto-percept)
attr "address_number" (type int) (range 1 9999) (mech obs) (auto-percept)

# Conversation
attr "initiator" (type entity) (entity "human_player" "human_npc") (mech obs) (auto-percept)

# Fluid
attr "fluid_amount" (type float) (range 0 1) (mech obs) (auto-percept) (state-flags-tar @excl)

# PR-evi-A 2026-05-25 - the three plural-kind evidence attrs. Each holds
# up to 4 leaf-kind atoms of the named taxonomy; the transmitter plural-
# expands into repeated singular `{?host wound|stain|mark <atom>}` beliefs.
# State-name override (the bare attr name is plural; the underlying state
# label is singular). All /obs - perceivable to anyone looking. Wired
# onto body-part archetypes (wounds + stains + marks), prop and
# structure_part (stains + marks only - props don't bleed).
#
# Forensic-trace attrs. PR-evi-D 2026-05-27 unifies wound / stain / mark
# under a single `blemish` parent kind in Objects.mon; the `blemishes`
# attr below is the unified plural-kind attr that accepts any mix
# (puncture_wound + blood_stain + tool_mark on the same body-part / prop
# is one attr write, not three). The three legacy attrs (wounds /
# stains / marks) remain in place until shared_functions/yield_evidence
# is migrated to write to `blemishes` instead; new writers should
# target `blemishes` directly.
attr "blemishes" (type kind array 4) (state "blemish") (mech obs) (auto-percept)
attr "wounds"  (type kind array 4) (state "wound") (mech obs) (auto-percept)
attr "stains"  (type kind array 4) (state "stain") (mech obs) (auto-percept)
attr "marks"   (type kind array 4) (state "mark")  (mech obs) (auto-percept)

# Transaction
attr "at" (type entity) (entity "structure" "container_structure" "space") (mech obs) (auto-percept)

# Instance
attr "prototype" (type entity) (spec-attr prototype) (imperceptible)

# Navigation v2 (see Merlin/Docs/nav_v2_plan.md)
# /is_nav_passage - runtime gate: 1 = passable, 0 = dormant. Action handlers
#   flip this on the opening entity (door/gate/large_window). nav_graph
#   subscribes and toggles the corresponding macro-graph passage edge.
# /nav_mesh - Hstr cache key for the structure's baked nav-mesh data;
#   written by Player at scene load when an island is registered.
# Throat geometry, opening identity and binding are all derived at scene-
# load from the opening Merlin entity's own TransformComponent (position,
# rotation, scale-as-half-extents per mx_radii_from_world_scale) plus its
# spatial relationship to nearby nav-meshes. No /opening_name attr; no
# /passage_throat_obb attr.
attr "is_nav_passage" (type int) (range 0 1) (is-nav-passage) (mech obs)
attr "nav_mesh" (type str) (nav-mesh) (imperceptible)
# /blocks_nav_terrain - when 1, the entity's OBB footprint rasterises as a
# terrain-walkability blocker during t_nav_terrain::build (nav_v2_plan.md §7).
# Defaults to 0 on plain `structure`; archetypes that physically obstruct the
# ground (buildings, walls, fences, gates, large rocks, tree trunks) override
# to 1 in their own .arc file. Connector throat clearing (§7.3) overrides
# this for cells under a structure's door, so a building with /blocks_nav_terrain
# = 1 still allows path entry through its baked-passage doorway.
attr "blocks_nav_terrain" (type int) (range 0 1) (blocks-nav-terrain) (imperceptible)

# Navigation v2 Phase 3 - road spline geometry.
# Per-entity authored road geometry: up to 16 centripetal Catmull-Rom CVs,
# width in metres, auto-junction radius (default 1.0m), and flags. The CVs
# come from the GrymEngine SplineComponent + RoadComponent the artist
# placed; Game.cc's LoadScene bridge reads them and calls
# mx_write_spline_attr per road entity. Junctions are auto-derived at
# scene load by Environment::resolve_road_network clustering endpoints;
# no junction archetype, no /junction attr.
# See Merlin/Docs/road_network_plan.md.
attr "spline_geometry" (type spline) (spline-geometry) (imperceptible)
