# Common attr definitions - shared across archetypes.
# Each attr name is defined exactly once here. Archetypes reference them by name.
# Every attr MUST declare an explicit transmission mechanism: /obs, /feel, /hear, /read, /imperceptible
# Use /state_flags_tar, /state_flags_sub, /state_flags_aux for per-field @-flags (pipe-separated).

# Identity & metadata

# NOTE: "isa" (kind attr) is auto-created on every population - no need to declare it.

# Lifecycle dates (used by historical sim; persist into interactive).
attr "birth_date" (type date) (spec-attr date) (per feel)
attr "death_date" (type date) (state-flags-tar @excl) (imperceptible)
attr "death_cause" (type kind) (imperceptible)

# Provenance marker (diagnostics). 1 = this NPC was created WITHOUT parents - a
# founder, or an immigrant minted from a parent-less spec - so it legitimately
# holds NO {@self mother/father} belief. 0 = born in-sim with parents (kin
# seeded by mx_make_human's assert_kin_beliefs). Set once at creation in
# mx_make_human. Lets diagnostics (hsim `kin-census`, the Talkie kin picker)
# tell "no parent belief because founder/immigrant" (expected) apart from "no
# parent belief because the kin belief was lost or never seeded" (a bug).
attr "parentless" (type int) (range 0 1) (imperceptible)

# Name attr. For humans: cognitively KNOWN, not felt (you don't sense your
# name as a body feeling - you reason about it); externally imperceptible (you
# can't tell a stranger's name by looking at them). Beliefs land in the
# REASON pool, no perception loop confirms or disproves them, so the name
# persists as long as the holder keeps the belief. Structure-style entities
# (buildings, roads) override (ext-per obs) per-archetype because their names
# WILL eventually be observable via address signs - for now those archetypes
# also add (auto-percept).
attr "name" (type name) (spec-attr name) (int-per reason) (ext-per imperceptible)

# Spatial
attr "obb" (type obb) (spec-attr spatial-bounds) (per obs) (auto-percept) (state-flags-tar @excl)
# Parent relationships are kept in the ECS for efficiency (technically redundant with parts)
attr "struct_parent" (type entity) (entity "structure" "container_structure" "structure_part" "part" "interior_space" "exterior_space" "hand" "human_player" "human_npc") (spec-attr parent) (per obs) (state-flags-tar @excl)
attr "parts" (type entity array 12) (state "part") (spec-attr children) (int-per feel) (ext-per obs)

# Ownership & control
# The entity currently controlling the position of this entity (if any)
attr "controlled_by" (type entity) (spec-attr controlled-by) (imperceptible)
# Durable OWNER of this entity: whoever created it (general rule - you make it,
# you own it). IMPERCEPTIBLE: ownership of a SECRET cache is not visible to
# others (the whole point), and the owner drives "observe your OWN cache".
attr "owner" (type entity) (imperceptible)
# What this entity controls (stowed or held items)
attr "control" (type entity array 12) (spec-attr control) (per obs) (auto-percept)
# Which stack this entity is in, if any. If not in a stack, set to _.
attr "in_stack" (type entity) (entity "stack") (spec-attr in-stack) (per obs)
# The person a document (letter) is addressed to. hsim-perceptible: the envelope
# addressee is visible on sight, so a mind that observes the letter internalizes
# {letter addressee <person>} - WITHOUT learning the message (that needs reading).
# The role-based mail-reading binds a letter via this belief.
attr "addressee" (type entity) (per obs) (auto-percept) (hsim-percept)

# Conditions & properties. Conceptual: kind-typed; @excl lives on the concept.
# condition is hsim-perceptible: liveness (alive/dead) is visible on sight, so a
# hsim mind that observes someone internalizes {them condition alive|dead} - the
# perception-native replacement for an explicit liveness mint.
attr "condition" (type kind alive) (per obs) (auto-percept) (hsim-percept)
attr "color" (type kind) (per obs) (auto-percept)

# Sensors & motors
attr "visual_sensor" (type visual-sensor)
attr "sound_sensor" (type sound-sensor)
attr "physical_motors" (type physical-motors)

# Body structure
# Hands are integral to reasoning - they get their own attrs even though they also appear in parts.
# Body parts are FELT internally (the NPC always knows their own body) AND observed externally
# (others see your hands when they look at you). Same int-feel-ext-obs split as `name`.
attr "left_hand" (type entity) (entity "hand") (state "hand") (int-per feel) (ext-per obs) (auto-percept)
attr "right_hand" (type entity) (entity "hand") (state "hand") (int-per feel) (ext-per obs) (auto-percept)
attr "head" (type entity) (entity "head") (state "head") (int-per feel) (ext-per obs) (auto-percept)
attr "eyes" (type entity) (entity "eye") (state "eyes") (int-per feel) (ext-per obs) (auto-percept)
attr "mouth" (type entity) (entity "mouth") (state "mouth") (int-per feel) (ext-per obs) (auto-percept)
attr "ring_finger" (type entity) (entity "finger") (state "finger") (int-per feel) (ext-per obs) (auto-percept)
# PR-evi-A 2026-05-25 - the central body. Same int-feel-ext-obs split as
# head / hand / mouth. The default wound-site when a perpetration method
# row omits :wound-site.
attr "torso" (type entity) (entity "torso") (state "torso") (int-per feel) (ext-per obs) (auto-percept)
attr "wear" (type entity) (per obs) (auto-percept)

# Demographics
attr "game_role" (type kind) (per obs) (auto-percept) (unaware)
attr "age" (type int) (range 0 120) (spec-attr age) (per feel) (state-flags-tar @excl)
attr "age_group" (type int) (range 0 8) (spec-attr age-group) (per obs) (auto-percept) (state-flags-tar @excl)
# Perceptible life-stage (the @excl concept + its 8 band kinds live in
# Concepts.mon). age_band is what anyone SEES on sight - kind/gender/age-band are
# visible even to strangers - so it is (hsim-percept): a hsim mind that observes a
# person internalizes {them age_band <band>} via mx_observe, with NO explicit mint.
# OBS-only (like gender): self gets {@self age_band <band>} from the visual
# self-observe inside update_self_awareness (it mirrors the /hsim_percept set in
# hsim too). NOT int-feel - a feel+obs split on an @excl attr makes the FEEL and
# visual passes end each other's belief, churning the self band to /past.
# Recomputed from birth_date yearly (hsim::refresh_all_age_attrs) + at creation.
attr "age_band" (type kind) (per obs) (auto-percept) (hsim-percept)
# The +/-1 proximity window of age_band (a plural set of band kinds), perceived
# about OTHERS so the age-peers macro can test "same / adjacent band" without
# arithmetic in the .hs. ext-obs only: a mind never needs its own span.
attr "age_span" (type kind array 3) (per obs) (auto-percept) (hsim-percept)
# gender / appearance / height / girth are conceptual: kind-typed, value is an
# ontology term. @excl now lives on the concept in Concepts.mon (rule 4b / 5).
attr "gender" (type kind) (per obs) (auto-percept) (hsim-percept)
attr "appearance" (type kind) (per obs) (auto-percept)
attr "height" (type kind) (per obs) (auto-percept)
attr "girth" (type kind) (per obs) (auto-percept)
# Hair / eye colour - observable physical traits (serial_predation
# generalized fixation). Kind-typed; seeded at creation from the
# hereditary trait tables (hair_color.txt / eye_color.txt).
attr "hair_color" (type kind) (per obs) (auto-percept)
attr "eye_color" (type kind) (per obs) (auto-percept)
# nationality and social standing are not physical environment state - they
# exist solely as beliefs (nationality / class_situation labels in States.mon).

# Personality & internal. sexual_orient is kind-typed; @excl lives on the
# concept in Concepts.mon. Interests are NOT physical - they are seeded
# directly as {@self interest <kind>} self-beliefs in mx_make_human (kinds
# sampled from the `interest` subtree in Concepts.mon) and propagated via the
# friend-tier belief mirror.
attr "sexual_orient" (type kind) (per feel)

# Fatigue, the continuous physical tiredness state (0 rested .. 1 ready-for-bed,
# can exceed 1 when sleep is denied). Imperceptible: the physiological scalar is
# never auto-mirrored into the mind as a belief - the alertness appraiser
# de-quantizes it into a discrete {@self alertness alert|tired|sleepy} belief
# (the queryable memory). The rest lane reads it for the sleep-pull utility; the
# sleep act's completion reduces it (1/6 per hour slept), waking time accrues it.
attr "fatigue" (type float) (range 0 2) (imperceptible) (state-flags-tar @excl)

# Hunger, the continuous physical need-to-eat state (0 just-ate .. 1 very
# hungry, can exceed 1 when meals are missed). Imperceptible, like fatigue:
# the physiological scalar is never auto-mirrored as a belief - the satiety
# appraiser de-quantizes it into a discrete {@self satiety sated|hungry|
# famished} belief (the queryable memory). Waking AND sleeping time accrue it
# (you wake hungry); meal-act completions reduce it (meal size is authored in
# the meal events via set-attr). Meal-lane eligibility reads it as a gate;
# meal UTILITY is proximity to the household mealtime, never hunger
# (tell-only comms plan, ruling 10) - hunger re-enters utility only at the
# famished starvation tail.
attr "hunger" (type float) (range 0 2) (imperceptible) (state-flags-tar @excl)

# Emigration marker (0 / 1). Set by (mark-emigrating @self) in the per-NPC
# emigration think event; the zero-role (sweep-emigrants) world-act collects
# every entity carrying it and destroys them (mark-then-sweep, like burial).
# Imperceptible - leaving is a private decision, not a visible-on-sight trait.
attr "emigrating" (type float) (range 0 1) (imperceptible)

# Accumulated intoxication, 0..1 - the get-drunk seed event bumps it; the F3.7
# sobriety classifier reads it (see hsim_derive.cc).
attr "intoxication" (type float) (range 0 1) (int-per feel) (ext-per obs) (state-flags-tar @excl)

# Gambling addiction, 0..1 (1 = morbidly addicted) - a behavioural addiction,
# the standing DISPOSITION to gamble (not an act, not a specific game). The
# gambling seed event bumps it; the sobriety + wealth classifiers read it
# (graded). (int-per feel) mirrors it into the NPC's own mind as a self-belief.
# The addiction is what makes {@self play_game <game>} for a `gambling`-facet
# game more likely (realised via event chance / the action pipeline's drive
# weighting). Supersedes the old `play_game gambling` act-record.
attr "gambling_addiction" (type float) (range 0 1) (int-per feel) (ext-per obs) (state-flags-tar @excl)

# Big Five personality - the ten aspects of the Big Five Aspect Scale
# (DeYoung/Quilty/Peterson 2007), two per OCEAN domain. Genetic and heritable
# (gaussian + mid-parent blend in mx_make_human), self-known via /feel. Each
# is a 0..1 float, population mean 0.5. Mirrored as {@self <aspect> <f>}
# self-beliefs; the appraisal pipeline, mood and the F3 classifiers read them.
attr "openness"        (type float) (range 0 1) (per feel) (state-flags-tar @excl)
attr "intellect"       (type float) (range 0 1) (per feel) (state-flags-tar @excl)
attr "industriousness" (type float) (range 0 1) (per feel) (state-flags-tar @excl)
attr "orderliness"     (type float) (range 0 1) (per feel) (state-flags-tar @excl)
attr "enthusiasm"      (type float) (range 0 1) (per feel) (state-flags-tar @excl)
attr "assertiveness"   (type float) (range 0 1) (per feel) (state-flags-tar @excl)
attr "compassion"      (type float) (range 0 1) (per feel) (state-flags-tar @excl)
attr "politeness"      (type float) (range 0 1) (per feel) (state-flags-tar @excl)
attr "volatility"      (type float) (range 0 1) (per feel) (state-flags-tar @excl)
attr "withdrawal"      (type float) (range 0 1) (per feel) (state-flags-tar @excl)

# Dark-tetrad personality - a separate four-trait malevolence overlay on the
# Big Five. Same 0..1 float scale and gaussian/heritable synthesis, but never
# mirrored across the boundary (believe_about Band 5) - an NPC's malevolence
# stays secret. Drives crime motives (Phase 10).
attr "narcissism"       (type float) (range 0 1) (per feel) (state-flags-tar @excl)
attr "machiavellianism" (type float) (range 0 1) (per feel) (state-flags-tar @excl)
attr "psychopathy"      (type float) (range 0 1) (per feel) (state-flags-tar @excl)
attr "sadism"           (type float) (range 0 1) (per feel) (state-flags-tar @excl)

# Physical traits (PR-3b 2026-05-25). 0..1 floats with population mean 0.5,
# parallel shape to the Big Five aspects. Genetic + heritable (mid-parent
# gaussian, to be wired in mx_make_human alongside the existing personality
# synthesis); age-decay over the lifespan lands in a follow-up. Both /feel
# (the NPC's own body-awareness) and /obs (others observe build, gait,
# stamina from outward signs). Read by perpetration.hsc method rows via
# (attr ?actor <trait>) gates - strength for bludgeon/strangle, dexterity
# for stab/garrotte (hand-and-finger precision), agility for climb/evade
# (whole-body acrobatics), endurance for pursuit/sustained fights.
attr "strength"   (type float) (range 0 1) (int-per feel) (ext-per obs) (state-flags-tar @excl)
attr "dexterity"  (type float) (range 0 1) (int-per feel) (ext-per obs) (state-flags-tar @excl)
attr "agility"    (type float) (range 0 1) (int-per feel) (ext-per obs) (state-flags-tar @excl)
attr "endurance"  (type float) (range 0 1) (per feel) (state-flags-tar @excl)
# Physical attractiveness / mate-value. 0..1
# float, mean 0.5, genetic + heritable (rolled in k_continuous_traits).
# (ext-per obs) - looks are publicly visible, so it mirrors at all tiers
# (believe_about band1); (int-per feel) gives self-awareness of it. Feeds the
# attraction stance scalar.
attr "attractiveness" (type float) (range 0 1) (int-per feel) (ext-per obs) (state-flags-tar @excl)
# Liquid savings ("money in the bank"). SIGNED - can go negative (debt) when
# gambling losses outrun income. Accrues
# yearly in derive_prototypes (savings from job rank, taxed by gambling), feeds
# classify_wealth, and transfers to the heir on death (propagate_death ->
# inherit_money). Not a rolled genetic trait - starts at 0 and accumulates.
attr "bank_balance" (type float) (range -100000 1000000) (per feel) (state-flags-tar @excl)

# Relationships
attr "pregnant_when" (type date) (per obs) (auto-percept)
# Only used to pass on appropriate DNA from the father
attr "pregnant_by" (type entity) (imperceptible)

# Region - updated by Environment, self-perceived via /feel
attr "region" (type entity) (entity "region") (spec-attr region) (per feel) (state-flags-tar @excl)

# Activity - remaps perceived target & aux to kind and place of the activity
attr "perform" (type entity) (entity "activity") (lookup-target "isa") (lookup-aux "location") (per obs) (auto-percept)

# Sound
# Holds the specific action that produced this sound (e.g. {john SAY (msg...) sam}).
# Imperceptible so we perceive the createAction on its own, not embedded in the sound.
attr "create_action" (type pattern) (spec-attr create-action) (imperceptible)
attr "speaker" (type entity) (entity "human_player" "human_npc") (spec-attr speaker) (imperceptible)
attr "preroll" (type float) (range 0 10) (spec-attr preroll) (imperceptible)

# Prop-specific
# A writing is a Merlin pattern holding a document's content - a (msg ...)
# wrapper around one or more belief sentences. /read transmits it to a
# reader's mind, where the sentences are evaluated into beliefs.
attr "writing" (type pattern) (per read) (state-flags-tar @msg @S)
# How hard the entity is being gripped. 0=loose, 1=hard
attr "control_force" (type int) (range 0 1) (imperceptible)

# Stack
attr "stack_label" (type str) (per obs) (auto-percept) (state-flags-tar @excl)
# Cap sized for the mail model: a read-mail stack accumulates a household's
# whole correspondence history, and the police station's report archive holds
# every crime report ever filed (128 filled by sim-year 12 of a 20yr run).
attr "items" (type entity array 512) (per obs)
attr "top" (type entity) (per obs) (state-flags-tar @excl)

# Weather (region)
attr "rain" (type kind heavy) (per obs) (auto-percept)
attr "snow" (type kind none) (per obs) (auto-percept)
attr "fog" (type kind none) (per obs) (auto-percept)
attr "wind" (type kind none) (per obs) (auto-percept)
attr "sky" (type kind clear) (per obs) (auto-percept)

# Region mood - non-sentient archetype, so per Q4 we keep mood state on the
# region itself as parallel-array attrs. Updated by run_region_mood_pass.
attr "mood_kinds" (type kind array 8) (state "mood") (per obs) (auto-percept)
attr "mood_intensities" (type int array 8) (range 0 100) (per obs)
attr "mood_set_dates" (type date array 8) (imperceptible)

# Building physical / structural properties.
attr "isolated"    (type int) (range 0 1) (per obs)
attr "has_crypt"   (type int) (range 0 1) (per obs)
attr "locked_wing" (type int) (range 0 1) (per obs)
# Era bounds - the building physically exists from era_min to era_max.
attr "era_min" (type date) (imperceptible)
attr "era_max" (type date) (imperceptible)
# Address (Section 4.12 exterior-spaces model). Two levels share this attr:
#   - a BUILDING's address -> its exterior address-SPACE entity (the location).
#   - that address-SPACE's address -> the road it fronts (with address_number).
# So a building's full street address is read FROM its address-space (the space's
# `address` road + `address_number`). Estates with no street self-reference.
# hsim-perceptible: observing a premise from the street mirrors {premise address
# <road>} + its number, so the road arrives as a known object through the belief
# target (roads are spline-only, never in the sector grid, never seen directly -
# address belief is the ONLY road-knowledge channel). Consumed by the Stage-5
# fringe policy (fringe-on-my-current-road).
attr "address" (type entity) (entity "road" "structure" "container_structure" "exterior_space") (per obs) (auto-percept) (hsim-percept)
attr "address_number" (type int) (range 1 9999) (per obs) (auto-percept) (hsim-percept)
# Apartment number (Section 4.12). INTERIOR spaces only: one building at one
# street address may hold several apartments, each an interior_space with its
# own number; rooms within carry it via their apartment's struct_parent. Distinct
# from address_number (the street number on the exterior address-space).
attr "apartment_number" (type int) (range 1 9999) (per obs) (auto-percept)

# Address-numbering POLICY (lives on the ROAD; see road.arc). Authored in the
# GrymEngine Spline Tool and pushed by the Player at scene load. These tell the
# shared sim-time numbering pass (merlin::assign_street_addresses_all) HOW to
# number the street_spaces fronting this road; the NUMBERS themselves are never
# authored, only generated. Imperceptible - policy, not an observable property.
#   address_even_side: 0 = even house numbers on the road's LEFT side, 1 = RIGHT.
#   address_start:     first house number assigned per side.
#   address_step:      increment between consecutive same-side numbers (2 = odd/even).
#   address_ascends_forward: 1 = low numbers at the first CV end, 0 = at the last.
attr "address_even_side" (type int) (range 0 1) (imperceptible)
attr "address_start" (type int) (range 1 9999) (imperceptible)
attr "address_step" (type int) (range 1 16) (imperceptible)
attr "address_ascends_forward" (type int) (range 0 1) (imperceptible)

# Conversation
attr "initiator" (type entity) (entity "human_player" "human_npc") (per obs) (auto-percept)

# Fluid
attr "fluid_amount" (type float) (range 0 1) (per obs) (auto-percept) (state-flags-tar @excl)
# Poison taint on a drink fluid (interrogation detail plan): the concrete
# poison kind (Objects.mon `fluid > poison`) a wine / tea / water fluid was
# laced with. IMPERCEPTIBLE - poison in a drink is not seen by looking; it
# is the forensic ground truth a chemical-analysis action reveals, the
# physical complement to the perpetrator's `add_substance` act-record
# belief (a fluid can be tainted with one poison at a time). Kind-typed so
# the value is an ontology term end to end.
attr "taint" (type kind) (imperceptible) (state-flags-tar @excl)

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
attr "blemishes" (type kind array 4) (state "blemish") (per obs) (auto-percept)
attr "wounds"  (type kind array 4) (state "wound") (per obs) (auto-percept)
attr "stains"  (type kind array 4) (state "stain") (per obs) (auto-percept)
attr "marks"   (type kind array 4) (state "mark")  (per obs) (auto-percept)

# Whereabouts - the place (building / room / space) an entity is located in.
# The universal location label: props use it for "the building this prop sits
# in" (evidence trails) and people use the matching belief for dated
# where-were-you memories. Replaces the retired `at` label.
attr "location" (type entity) (entity "structure" "container_structure" "interior_space" "exterior_space") (spec-attr location) (per obs) (auto-percept) (hsim-percept)

# Per-building loose-item index: the inverse of `location`. The set of loose
# props (weapons, tools, vessels, merchandise) whose `location` points at this
# building, maintained incrementally as items move (hsim set_prop_location).
# Lets "what is in this building" - store inventory, weapons to grab, loot to
# case - be a direct O(1) read instead of an O(world) entity scan. Imperceptible:
# this is env-side bookkeeping, NOT a perception source (prop knowledge is
# delta-driven via the relocation dirty-space pass on arrival/departure plus
# perceive_here's absence pass on return). Items remain loose entities - this is
# a reverse lookup, not containment/hierarchy.
# Cap 256: a whole-town gathering (church service, ~200+ souls) files every
# attendee into ONE room's contents alongside the room's furnishings.
attr "contents" (type entity array 256) (imperceptible)

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
attr "is_nav_passage" (type int) (range 0 1) (is-nav-passage) (per obs)
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
