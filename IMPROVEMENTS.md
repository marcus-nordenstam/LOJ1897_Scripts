IMPROVEMENTS

ANIM ISSUES:
* transitions too snappy - tweak durations
* ease-in/ease-out?
* walking looks too stilted
* when not walking anymore (running TURN_TO or HALT or other legs action?) legs should fade into IDLE anim
* fading in just a little of the idle motion.

BEHAVIOUR ISSUES:
* switch to relative utilities
* people should turn their head to face what they drink
* people should face each other when talking, etc.

ROBUSTNESS:
*  Player tries to interrupt ordering
*  NPC ordering is bumped out of their cell
*  SLOW down when approaching destination / don't overshoot, take frame-rate into account
*  Bartender stops bartending: patrons should not get stuck
*  Patron stops wanting a drink: bartender should not get stuck

IMPROVEMENTS:
* Patrons step away from the bar when done ordering, to let others in?
* Mark some tables, so patrons put their empty glasses on tables
* Bartender picks up empty glasses and destroys them

GENERAL CLEANUP:
* Rigourously define: cell-overlap.  
   Used by (overlaps), but also check how the mx_cell/worlspace mapping work w.r.t that
   Should talking distance be based on cell coords or worldspace coords? pros and cons

/cont = continuous evaluation
/interval x y = continuous with cooldown - using cycles instead of seconds for x y args
/discrete = discrete evaluation (suppress any continuous funcs)


HISTORICAL SIM:

* Establish occupations

* Establish areas and roads, roads have names and numbered range of addresses.
* For now, there is the town of Port Christie on the English side of the island, 
  and Valette is the town on the French side of the island - quite hilly - and 
  Haven is the industrial town south of Port Chrisite.  All three towns will have some streets.
  Most middle-class and upper class homes will be outside the towns.  Upper-class homes
  will usually be estates, where the address is not really a numbered road, but usually just
  the name of the estate.
* Establish residential housing in env.
* Establish commercial buildings for businesses for different occupations in env.
* Buildings can be detailed simply as tiny, small, large, huge, and given an address.

* Wealthy NPCs may not need an occupation; some are landlords however
* Middle classes and below do need an occupation - so pick one from the list
* Establish where each NPC lives and the arrangement: renting or owning.
* Generally speaking if you are wealthy you own.  Else, if your occupation allows, you own, else you rent.

* Rules regarding changing residence:
* You leave the house for university or boarding school - if you go to school (only the wealthy).
* You move to your own house as soon as you have a job that lets you, unless you are wealthy in which case
  you may stay in your parent's mansion until you marry.
* When you marry, if you are a woman, you move into your husband's house.

* When an NPC dies, the children inherit.  For now we just go by age, so the oldest inherits everything
(This can cause jealousy!)



Merlin PERCEPTION improvements

  Voluntary path (attention set + stack)

  1. No dirty-flag gate. Both loops always call perceiveAttendedEntity, which runs two visibility checks and then
  perceiveEntityAttrs — even when nothing has changed on the entity since last perception. The involuntary path already
  gates on latestExtPerceptChangeCycle >= receiverPerceptCycle (line 984), but the voluntary path skips this entirely.
  Adding the same check before the visibility computation would eliminate the most expensive work for unchanged
  attention targets.

  2. Wasted mental visibility check on stack path. perceiveAttendedEntity always runs computeVisibility against the
  mental OBB (line 114-116), but this is only needed for lost-sight detection. When handleLostSight=false (the stack
  path), that raycast is pure waste. The function should skip it.

  Involuntary path (sector sweep)

  3. Salience is purely temporal. The metric is cyclesSinceLastAttempt (line 996-997). A tiny object across the room
  that hasn't been checked in 100 cycles beats a large person who just walked in 2 cycles ago. The original discussion
  mentioned factoring in:
  - Object size (radius) — large entities are more visually salient
  - Proximity — close entities dominate the visual field
  - Sudden appearance — entity entered visible sectors this cycle

  None of these are currently considered.

  4. No sudden-appearance handling. _updateVisibleSectors computes startObservingSectorIndices (sectors that just became
   visible), but observe() doesn't use it. Entities in newly-visible sectors could be given a salience boost or
  immediately flagged, rather than waiting for the temporal salience to accumulate.

  5. Fixed top-4 cap. In a sparse scene with 1 changed entity, we still iterate all sectors to rank 4. In a dense scene
  with 20 changed entities, we only perceive 4 per cycle, which may cause important state changes to be missed for many
  cycles. The cap doesn't adapt to scene density or entity importance.

  Structural

  6. entityIdOccurs is O(n) linear scan on up to 96 entries, called per occupant in the sector sweep. With many
  occupants this adds up. A bitset or hash set indexed by entity index would be O(1).

  7. The attention set object field is a mental Symbol, requiring mental→abs→EntityId translation each cycle even for
  stable attention targets. Caching the EntityId alongside the Symbol in AttentionObject would avoid the
  passivelyExternalizeSymbol + rawEntityId() lookup each cycle.

  ---
  Which of these do you want to tackle? The dirty-flag gate on the voluntary path (point 1) and the salience heuristic
  (point 3) seem like the highest-value changes relative to the original design discussion.

// 1. Reduce the intake:
//    * Any event whose relation-label never occurs as a decl.condition or in a search can be
//      trivially forgotten.  Alternatively, we discard it instead of committing it.
//      If the player asks about things like what we're forgetting, we can use reasoning rules to
//      come up with answers.
//    * By default, we only observe large objects and large spaces, and groups of things.
//      And we don't observe child-objects.
//    * Instead, all tasks should include explicit observe actions to ensure the NPC is observing
//      what is necessary to perform the task at hand.  For example, in giving/taking, both parties
//      should be observing each others hands.







Merlin RETE improvements


---
  Merlin Eps vs CLIPS RETE: Detailed Comparison

  1. Architecture at a Glance

  ┌─────────────────┬────────────────────────────────────────────┬──────────────────────────────────────────────────┐
  │     Aspect      │                 Merlin Eps                 │                    CLIPS RETE                    │
  ├─────────────────┼────────────────────────────────────────────┼──────────────────────────────────────────────────┤
  │ Alpha network   │ Label-indexed hash table (type × label)    │ Dataflow network of alpha-test nodes (one test   │
  │                 │                                            │ per node, chained)                               │
  ├─────────────────┼────────────────────────────────────────────┼──────────────────────────────────────────────────┤
  │ Beta network    │ Join nodes + response nodes                │ Join nodes, negative nodes, NOT-CE nodes, exists │
  │                 │                                            │  nodes, terminal nodes                           │
  ├─────────────────┼────────────────────────────────────────────┼──────────────────────────────────────────────────┤
  │ Tokens          │ Parent-pointer tree (EpsToken)             │ Left-linked token list (similar concept)         │
  ├─────────────────┼────────────────────────────────────────────┼──────────────────────────────────────────────────┤
  │ WME tracking    │ WmeRefs per WME (back-pointers to alpha    │ Similar: each fact tracks alpha-memory           │
  │                 │ memories + tokens)                         │ memberships                                      │
  ├─────────────────┼────────────────────────────────────────────┼──────────────────────────────────────────────────┤
  │ Conflict        │ None — rules fire immediately when         │ Agenda with LEX or MEA or depth/breadth/random   │
  │ resolution      │ activated                                  │ strategies                                       │
  ├─────────────────┼────────────────────────────────────────────┼──────────────────────────────────────────────────┤
  │ Negation        │ Not supported                              │ Full support (negated CEs, exists, forall,       │
  │                 │                                            │ logical)                                         │
  ├─────────────────┼────────────────────────────────────────────┼──────────────────────────────────────────────────┤
  │ Node sharing    │ Yes — findSharableJoinNode() shares nodes  │ Yes — extensive sharing of both alpha and beta   │
  │                 │ across rules                               │ nodes                                            │
  └─────────────────┴────────────────────────────────────────────┴──────────────────────────────────────────────────┘

  2. Where CLIPS Does Things Merlin Doesn't (and Whether They Matter)

  2a. Negated Conditions (Negative Join Nodes)

  CLIPS supports (not (pattern)), (exists (pattern)), and (forall ...). These use special negative join nodes that track
   a count of matching WMEs; the node activates its successors only when the count hits zero (for not) or becomes
  non-zero (for exists).

  Relevance to Merlin: Your codebase comment at Eps.h:398 explicitly says "the rule-engine does not handle negative
  conditions." For NPC AI, negation is actually useful — "if NOT holding a weapon, flee" or "if no nearby allies, act
  cautiously." However, there's a simpler alternative you may already be using: checking for negation in function
  conditions (the imperative side) rather than the declarative RETE side. If that covers your use cases adequately,
  adding full RETE negation might add complexity without proportionate benefit. If you find yourself writing a lot of
  awkward function-condition workarounds for what would naturally be "absence of a fact," it might be worth adding a
  lightweight negative-join node type.

  2b. Conflict Resolution Strategy (Agenda)

  CLIPS maintains a priority-sorted agenda of activated rule instantiations. Rules don't fire immediately upon match —
  they're queued and the conflict resolution strategy (LEX, MEA, salience, etc.) determines which fires next. This
  means:

  - Rules with higher salience fire first
  - LEX/MEA use recency of matched facts to break ties
  - After one rule fires and changes WME state, the agenda is updated before the next firing

  Merlin's approach: Rules are queued into rulesToFireNextCycle / rulesToEvaluateNextCycle and sorted by lockPriority
  via stable_sort (Eps.h:319-325). This is a simpler model — essentially a one-level priority with cycle-based batching.

  Relevance: For NPC simulation running at ~10-30Hz, the cycle-based batching is fine. CLIPS's sophisticated
  recency-based tie-breaking (LEX/MEA) exists because CLIPS rules often form long inference chains where firing order is
   semantically important. In a game NPC, you don't typically have deep inference chains — your rules are more reactive.
   The lockPriority approach is well-suited. One potentially useful idea from CLIPS: salience partitioning — grouping
  rules into priority bands (e.g., "emergency" > "combat" > "social" > "idle") so that the entire "emergency" band is
  exhausted before any "combat" rule fires. If you don't already have this, it's a cheap win for NPC behaviour
  authoring.

  2c. Truth Maintenance (Logical Support)

  CLIPS's (logical ...) CE allows facts to be automatically retracted when their logical support is removed. If rule R
  asserts fact F because conditions A and B held, and B is later retracted, F is automatically retracted too.

  Relevance: Merlin already has a form of this — when a WME is removed, eraseTokensAndDescendants cascades through the
  token tree, deactivating ground rules. But it doesn't auto-retract facts asserted by those rules. For NPC AI, this
  could be useful for derived beliefs: "I believe the door is locked" was derived from "I heard a click" — if the click
  event expires, the belief should too. Whether this is worth implementing depends on how much manual belief cleanup
  you're currently doing in response actions.

  3. CLIPS Optimizations Merlin Could Benefit From

  3a. Hashed Beta Joins (HIGH IMPACT)

  This is the single biggest optimization CLIPS has that Merlin lacks.

  In Merlin's alphaActivationJoin() (EpsActivation.h:393-399), when a new WME arrives at a join node, it iterates every
  token in the parent node and runs performJoinTests() against each:

  for (auto parentMatchingToken : nodeParent->items) {
      if (performJoinTests(context, node, parentMatchingToken, alphaWme)) {
          ...
      }
  }

  Similarly, in betaActivationJoin(), it iterates every WME in the alpha memory.

  CLIPS optimizes this with hash tables on join variables. When a join test compares field X of the incoming WME against
   field Y of existing tokens, CLIPS pre-indexes the tokens (or alpha-memory WMEs) by the value of that field. The join
  then does a hash lookup instead of a linear scan.

  For Merlin: If an NPC has, say, 200 beliefs and a join node tests ?actor, you're doing 200 comparisons per activation.
   With a hash on ?actor, you'd do O(1) lookups. This matters when:
  - NPCs have many active beliefs/events in WM
  - Rules have early conditions that match broadly (e.g., "any event where ?actor is someone I know")
  - Multiple NPCs means the total WM can grow

  Implementation sketch: For each join node with a single-field equality test, maintain a hash map field_value →
  list<EpsToken*> alongside the existing items array. Update it on token add/remove. During join, look up by value
  instead of scanning. Only do this for nodes where items.size() exceeds some threshold (say 16) — for small nodes,
  linear scan is faster due to cache locality.

  3b. Alpha Network Hashing (You Already Have This, Partially)

  CLIPS uses a hash table indexed by the first field of each fact to select alpha memories. Merlin already does this
  with alphaMemoryTable[type][label] — you're hashing on the event label. This is good.

  CLIPS goes one step further: it can hash on multiple fields in the alpha network (not just the first). For Merlin, the
   label-only indexing is probably sufficient since your patterns are semantically typed by label, but if you ever find
  alpha memory fan-out becoming a bottleneck, consider a composite key.

  3c. Condition Ordering Optimization (MODERATE IMPACT)

  CLIPS doesn't do this automatically (the programmer orders conditions), but the CLIPS literature strongly recommends
  placing most restrictive conditions first to minimize the size of partial-match sets in the beta network.

  Merlin appears to process conditions in the order they appear in the rule (I found no evidence of reordering in
  EpsCreation.h). For NPC rules, an automatic or semi-automatic condition reordering heuristic could help:

  - Place conditions with the fewest expected WME matches first (e.g., conditions on rare event types)
  - Place conditions that introduce the most-constrained variable bindings early
  - Place conditions with constants (which filter in the alpha network) before purely-variable conditions

  This is a compile-time / rule-load-time optimization — zero runtime cost. Even a simple heuristic ("conditions with
  more constant fields go first") could reduce token counts significantly.

  3d. Right Unlinking (MODERATE IMPACT)

  CLIPS implements right unlinking: when a join node has zero tokens in its left (parent) input, it temporarily
  disconnects itself from its alpha memory. This means new WMEs flowing through the alpha network skip join nodes that
  can't possibly produce matches (because there are no left-side tokens to join with).

  In Merlin, alphaActivationJoin() always visits every successor join node of an alpha memory, even if nodeParent->items
   is empty. The check at line 375 handles the dummy-top-node case, but there's no short-circuit for empty parent nodes
  in general.

  Implementation: When a join node's parent token count drops to zero, remove it from the alpha memory's successor list.
   When the parent gets its first token, re-link. This avoids the overhead of entering alphaActivationJoin(), running
  the tracing code, and discovering there's nothing to join with.

  3e. Left Unlinking (Symmetric)

  The mirror of right unlinking: when an alpha memory has zero WMEs, disconnect the join node from its parent's child
  list. New tokens flowing down the beta network skip nodes whose alpha memories are empty. Same principle, same
  benefit.

  4. Things Merlin Does Well That CLIPS Doesn't Prioritize

  - Arena/pool allocation: Merlin's ArenaPool for tokens, nodes, and WMEs is excellent for game runtime. CLIPS uses
  general-purpose malloc, which is slower and fragments.
  - Per-mind isolation: Each NPC has its own Eps network and WM. CLIPS has a single global fact space (with modules for
  namespace control, but not true isolation). Merlin's design is better for concurrent NPC simulation.
  - Gamma memory tracking: The gamma-memory system for re-evaluating active ground rules when their matched patterns
  change is a nice refinement that CLIPS doesn't have in quite this form.
  - Cycle-based batching: Processing all pattern changes in a batch per tick (commitPatternChanges) is well-suited to
  game frame timing. CLIPS processes changes incrementally (better for interactive shells, worse for fixed-timestep
  games).
  - Fixed-size containers: FixedArray<EpsNode*, 16> for alpha memory successors, etc. — avoids heap allocation and keeps
   data cache-friendly. Good for real-time.

  5. Prioritized Recommendations

  ┌──────────┬──────────────────────────────────────────────┬────────┬──────────────────────────────────────────────┐
  │ Priority │                    Change                    │ Effort │               Expected Impact                │
  ├──────────┼──────────────────────────────────────────────┼────────┼──────────────────────────────────────────────┤
  │ 1        │ Hashed beta joins for high-fanout join nodes │ Medium │ Significant — reduces O(N) scans to O(1)     │
  │          │                                              │        │ lookups on hot paths                         │
  ├──────────┼──────────────────────────────────────────────┼────────┼──────────────────────────────────────────────┤
  │ 2        │ Right/left unlinking of empty nodes          │ Low    │ Moderate — avoids wasted work in sparse      │
  │          │                                              │        │ networks                                     │
  ├──────────┼──────────────────────────────────────────────┼────────┼──────────────────────────────────────────────┤
  │ 3        │ Condition reordering heuristic at rule load  │ Low    │ Moderate — smaller intermediate token sets   │
  │          │ time                                         │        │ throughout the network                       │
  ├──────────┼──────────────────────────────────────────────┼────────┼──────────────────────────────────────────────┤
  │ 4        │ Lightweight negative joins (count-based, not │ Medium │ Simplifies rule authoring for "absence"      │
  │          │  full CLIPS semantics)                       │        │ conditions                                   │
  ├──────────┼──────────────────────────────────────────────┼────────┼──────────────────────────────────────────────┤
  │ 5        │ Salience partitioning / priority bands       │ Low    │ Quality-of-life for behaviour authors        │
  └──────────┴──────────────────────────────────────────────┴────────┴──────────────────────────────────────────────┘

  6. What to Probably Skip

  - Full CLIPS-style logical/truth maintenance: Heavy to implement, and NPC belief management can be handled more simply
   via explicit rule responses or event expiry.
  - LEX/MEA conflict resolution: Designed for symbolic AI reasoning chains, not reactive NPC behaviour. Your cycle-based
   priority model is better suited.
  - General-purpose defmodule partitioning: Merlin's per-mind isolation already handles this better for the game NPC use
   case.
  - Multifield variables / fact-set queries: CLIPS power-user features for general-purpose programming. Your pattern
  matching is already well-suited to the fixed-field event/belief structure.

  ---
  The single biggest win would be hashed beta joins. If you profile Merlin and find that performJoinTests loops in
  alphaActivationJoin or betaActivationJoin dominate, hash indexing on the join variable would be transformative — it's
  the optimization that made CLIPS practical for large rule sets.


GRYM engine cleanup

 ---
  Part 1: Systems That Can Be Removed

  These exist solely as fallbacks for hardware without RT support.

  1. Software BVH Ray Tracing (HIGH priority)

  The engine maintains an entire parallel software ray tracing implementation:

  - wiGPUBVH.cpp / wiGPUBVH.h — CPU-side BVH builder, uploads nodes/primitives to GPU
  - raytracingHF.hlsli lines 85-420 — ~200+ lines of stack-based BVH traversal (TraceRay_Closest(), TraceRay_Any(),
  IntersectTriangle())
  - ShaderInterop_BVH.h — BVH node/primitive structs
  - Non-_rtapi shader variants — raytraceCS.cso, ddgi_raytraceCS.cso, surfel_raytraceCS.cso, renderlightmapPS.cso —
  these are the software-traced copies of every RT shader
  - wiScene.cpp:583-586 — BVH build path as alternative to TLAS
  - ~30 capability check branches in wiRenderer.cpp that select between _rtapi and software shaders

  This is the largest single removal candidate. Every RT system has a software twin.

  2. Screen-Space AO: SSAO + HBAO + MSAO (~875 lines of shaders)

  Three separate screen-space AO algorithms, all redundant with RTAO:

  ┌────────┬────────────────────────────────┬───────┐
  │ System │             Shader             │ Lines │
  ├────────┼────────────────────────────────┼───────┤
  │ SSAO   │ ssaoCS.hlsl                    │ 122   │
  ├────────┼────────────────────────────────┼───────┤
  │ HBAO   │ hbaoCS.hlsl                    │ 125   │
  ├────────┼────────────────────────────────┼───────┤
  │ MSAO   │ msaoCS.hlsl + 5 helper shaders │ 435   │
  └────────┴────────────────────────────────┴───────┘

  Plus C++ side: CreateSSAOResources(), Postprocess_SSAO/HBAO/MSAO(), SSAOResources struct, MSAOResources struct (16
  texture allocations for the multi-scale depth pyramid).

  The AO enum in wiRenderPath3D.h currently has 5 values — would collapse to just DISABLED / RTAO.

  3. Screen-Space Reflections (~1,100+ lines of shaders)

  Full hierarchical SSR system with multiple quality tiers:

  - ssr_raytraceCS.hlsl (391 lines), plus _cheap and _earlyexit variants
  - ssr_tileMaxRoughness_*.hlsl, ssr_depthhierarchy.hlsl, ssr_resolve.hlsl, ssr_temporal.hlsl, ssr_upsample.hlsl
  - C++: SSRResources struct, Postprocess_SSR(), depth hierarchy generation

  Already mutually exclusive with RT reflections (wiRenderPath3D.cpp line 1614: if (getSSREnabled() &&
  !getRaytracedReflectionEnabled())). With RT guaranteed, the SSR branch is dead code.

  4. Screen-Space GI (~400+ lines of shaders)

  - ssgiCS.hlsl (191 lines), ssgi_deinterleaveCS.hlsl, ssgi_upsampleCS.hlsl
  - C++: SSGIResources with atlas depth/color buffers, mip pyramids
  - Replaced by RT Diffuse / DDGI / Surfel GI

  5. VXGI — Voxel Cone Tracing (~20 shaders)

  This is a pre-RT era GI technique:

  - Voxelization: objectVS_voxelizer.hlsl, objectPS_voxelizer.hlsl, objectGS_voxelizer.hlsl
  - Cone tracing: voxelConeTracingHF.hlsli
  - Resolve: vxgi_resolve_diffuseCS.hlsl, vxgi_resolve_specularCS.hlsl
  - Temporal: vxgi_temporalCS.hlsl
  - SDF: vxgi_sdf_jumpfloodCS.hlsl
  - C++: VXGI_Voxelize(), VXGI_Resolve(), VXGIResources, flags VXGI_ENABLED / VXGI_REFLECTIONS_ENABLED

  Entirely superseded by DDGI + Surfel GI + RT Diffuse. The voxelization pass is also an extra geometry pass each frame
  — removing it saves a full scene traversal.

  6. Screen-Space Shadows (already gutted)

  SetScreenSpaceShadowsEnabled() is already a no-op. The remaining dead struct/function bodies can be cleaned out.

  7. Environment Probes (EVALUATE carefully)

  EnvironmentProbeComponent with cubemap capture exists. These are the classic fallback for reflections. However, probes
   may still serve a purpose for:
  - Sky/IBL fallback for rays that miss geometry
  - Distant environment approximation beyond RT range

  I'd recommend keeping the probe data for sky/IBL but removing the real-time cubemap re-rendering pipeline if RT
  reflections are always on.

  ---
  Part 2: Suboptimal Given Guaranteed RT Hardware

  1. DDGI Ray Budget — Very Conservative

  - Default: 256 rays/probe, hard cap: 512 (DDGI_MAX_RAYCOUNT in ShaderInterop_DDGI.h)
  - Modern RT cores can handle far more. Increasing to 1024+ rays/probe would dramatically reduce probe noise
  - The 512 hard cap is an artificial #define — no hardware reason for it

  2. Surfel GI Ray Budget — Uses ~1.7% of RT Capacity

  - Cap: 500,000 rays/frame (SURFEL_RAY_BUDGET in ShaderInterop_SurfelGI.h)
  - RTX 3000+ can trace ~100M rays/sec. At 60fps that's ~1.67M rays/frame budget for just surfels, and you're using 30%
  of that
  - Increasing to 2-5M rays/frame would significantly improve surfel coverage and convergence

  3. RT Diffuse Range — 10 Meters

  - rtdiffuseCS.hlsl traces only 10m. Indirect light from distant sources (a bright window across a room, sunlight
  bouncing off a far wall) is completely missed
  - With RT guaranteed, 50-100m range is practical
  - Also dispatched at half resolution — full-res is feasible with RT hardware

  4. RT Reflections Roughness Cutoff — 0.6

  - reflectionRoughnessCutoff = 0.6 in wiRenderPath3D.h — surfaces above 60% roughness get no reflections
  - Modern engines use 0.2-0.4 cutoff. This means moderately rough metals, wet surfaces, etc. lose reflections entirely
  - With RT guaranteed, lowering to 0.3-0.4 is practical

  5. Single-Ray Everything

  - RT Shadows: 1 ray/pixel/light — soft shadows rely entirely on denoising
  - RT Reflections: 1 ray/pixel — no temporal supersampling
  - RT Diffuse: 1 ray/pixel at half-res

  Multi-sample or stratified temporal sampling would reduce denoiser load and improve quality.

  6. No Multi-Bounce Reflections

  RT reflections are strictly single-bounce. A mirror facing a mirror shows nothing. With guaranteed RT, a 2-bounce
  falloff (full quality → simplified material on second bounce) is practical.

  7. BVH Rebuilt Every Frame

  wiScene.cpp rebuilds TLAS every frame regardless of whether geometry moved. With PREFER_FAST_BUILD possibly being the
  default, switching to:
  - PREFER_FAST_TRACE for static BLAS
  - Incremental TLAS updates (refit rather than rebuild for moving objects)
  - Skip rebuild entirely for frames with no transform changes

  8. FFX-DNSR Is Heavyweight

  The 3-pass FFX Denoiser for Shadows (tile classification → filter → temporal) is used for both RT shadows and RTAO.
  With more rays per pixel, a simpler bilateral + temporal filter would suffice and save 1-2 passes.

  ---
  Summary: Estimated Removable Code

  ┌────────────────────────────────┬─────────────────────────────┬───────────────────────────────────────┬──────────┐
  │             System             │        Shader Lines         │             C++ Footprint             │ Priority │
  ├────────────────────────────────┼─────────────────────────────┼───────────────────────────────────────┼──────────┤
  │ Software BVH + non-RTAPI       │ 200+ hlsl + duplicate       │ wiGPUBVH.cpp (13.5KB) + 30 branch     │ HIGH     │
  │ shaders                        │ shaders                     │ sites                                 │          │
  ├────────────────────────────────┼─────────────────────────────┼───────────────────────────────────────┼──────────┤
  │ SSAO/HBAO/MSAO                 │ ~875                        │ Resources + 3 postprocess fns         │ HIGH     │
  ├────────────────────────────────┼─────────────────────────────┼───────────────────────────────────────┼──────────┤
  │ SSR                            │ ~1,100                      │ Resources + postprocess fn            │ HIGH     │
  ├────────────────────────────────┼─────────────────────────────┼───────────────────────────────────────┼──────────┤
  │ SSGI                           │ ~400                        │ Resources + postprocess fn            │ MEDIUM   │
  ├────────────────────────────────┼─────────────────────────────┼───────────────────────────────────────┼──────────┤
  │ VXGI                           │ ~500+ (20 shaders)          │ Voxelize + Resolve + Resources        │ MEDIUM   │
  ├────────────────────────────────┼─────────────────────────────┼───────────────────────────────────────┼──────────┤
  │ Screen-space shadows (dead)    │ ~50 (gutted)                │ Dead structs                          │ LOW      │
  ├────────────────────────────────┼─────────────────────────────┼───────────────────────────────────────┼──────────┤
  │ RT capability branches         │ —                           │ ~30 if(CheckCapability) sites         │ HIGH     │
  └────────────────────────────────┴─────────────────────────────┴───────────────────────────────────────┴──────────┘

  Total removable: roughly 3,000+ lines of shader code, ~15KB+ of C++, ~8 duplicate shader files, and ~30 branch points
  that add complexity for a path you'll never take.








1. Cache-hit path skips the resource manager — latent dangling-resource bug

  wiScene.cpp:1653–1658 (cache hit) calls only tmp.componentLibrary.Serialize(...). Cache miss at :1667 calls tmp.Serialize(...), which goes through resourcemanager::Serialize_READ. The cached
  archive that's later deserialized never re-runs resource registration. Today this works only because the first miss registered resources globally and the resource manager keeps them alive. The
  moment a project starts unloading scenes / evicting cold textures / hot-reloading meshes, the cache hit path will deserialize components that reference resource handles whose underlying
  resources have been freed. This is a ticking time-bomb, not a current crash. The cache should either store the resource section too, or cache hits should re-register via Serialize_READ against
  the cached blob.

  2. Scene::ResolvePrefabChildReferences is a stub (wiScene.cpp:1819–1834)

  We build seri.prefab_child_refs on save, but resolution is // TODO. So any scene-level component holding an Entity that points into a prefab subtree will write a stale ID and read back garbage
  on load. MerlinComponent::entityAttrs (per its comment, "Serialized via SerializeEntity for correct prefab/scene remapping") relies on the standard EntitySerializer remap — that works for
  entities that are serialized; it does NOT work for prefab-children that are excluded from serialization and re-created on load with new IDs. The first time a level designer wires a Merlin
  entity-attr to a prefab-child entity, this will silently corrupt on save/reload.

  3. Topdown-hierarchy is rebuilt N times during scene load (wiScene.cpp:7948 + per-Instantiate at :1764)

  Each Instantiate calls StartBuildTopDownHierarchy() + WaitBuildTopDownHierarchy(). For a level with M prefab instances, that's M rebuilds — each scanning the growing scene. The rebuild was
  added because Merge bypasses Component_Attach. Easy win: do it once after the loop in Scene::Serialize, or accumulate work and rebuild lazily.

  4. ReinstantiatePrefab silently destroys local edits

  Sync button → Entity_Remove(child, false) for every child (wiScene.cpp:1779–1781). Anything the user dragged into the instance, repositioned, or attached is wiped with no warning. There's no
  override / delta system. Acceptable as a design choice but should at least warn on dirty children, or be split into "hard sync" vs "merge".

  5. PrefabInstComponent::file_timestamp is dead state

  Refreshed every Instantiate (wiScene.cpp:1625) and serialized — but never compared. PrefabWindow_ImGui::Update() has the placeholder (PrefabWindow_ImGui.cpp:186-190) but no actual check. It's
  the field you'd want for "this instance is stale, click sync" UI. Either implement or delete it; right now it's noise that clobbers itself on each instantiation.

  6. Cache key uses the un-normalized prefab_path

  Cache reads/writes use prefabComponent->prefab_path directly (wiScene.cpp:1641, 1672). But the path may be either relative (normal) or absolute (spawn library, see :1622-1624). The same prefab
  loaded by both paths becomes two cache entries, and clear_prefab_cache(rel_path) won't invalidate the absolute-path entry (or vice versa). Normalize once before keying.

  7. Absolute-path detection is fragile (wiScene.cpp:1623)

  pp[0] == '/' || pp[1] == ':' misses \\server\share UNCs and treats any string with : at position 1 as absolute (e.g., a malformed "X:foo"). Use a real path-classification helper.

  8. No cycle detection on nested prefabs

  A prefab whose subtree contains a PrefabInstComponent referencing itself (directly or via a chain) will recurse until stack overflow. Add a depth limit or visited-set guard in Instantiate.

  9. InstantiateDuplicate null-deref on un-named prefab (wiScene.cpp:1608-1609)

  names.GetComponent(prefabEntity) is dereferenced unconditionally. In current flows the prefab is always named, but nothing in the type system enforces that — a guard costs one line.

  10. Unpack button doesn't record children in undo history (PrefabWindow_ImGui.cpp:69-87)

  RecordEntity(archive, e) is called only for the prefab entity, before and after prefabs.Remove(e). The children — which transition from "excluded on save" to "saved as part of scene" — are not
  in the history record. Undo restores PrefabInstComponent but the children's state changes leak across the boundary.

  11. Pre-instantiation sky/weather pollution

  This isn't a bug per se, but: today anything in a .grs is dragged in when you instantiate, including the sun/moon/weather entities the prefab author left behind. Two scenes with prefabs end up
  with duplicate weather components, fighting over realistic-sky state. There's no current filter — your proposal directly addresses this.

  12. Minor / stylistic

  - PrefabInstComponent is the only Component in the codebase still using camelCase / Pascal naming for its struct name (PrefabInst) — minor, but if you're touching it, snake-case rename is a
  freebie consistent with the migration rule.
  - tmp.Serialize(prefabArchive, /*skip_ddgi=*/true) (:1667) is good, but tmp.componentLibrary.Serialize (:1657, :1676) doesn't take that flag and so silently relies on prefab archives never
  having DDGI sections. Brittle.



NAVMESH TODOS:



  1. Pre-allocated A* node pool — dtNodePool equivalent.
  Replace per-_plan std::priority_queue + std::unordered_map<t_uni_node, t_meta> with a fixed-capacity slab (sized by k_nav_max_polys_per_mesh) reused across plans. Index by (island_idx << 16) |
  poly_idx. Eliminates ~2 allocations per pathfind × N actors × replan rate. ~50 LOC in t_nav_graph.
  Can this be done using a simple FixedTable or FixedArray? Or must we use a pool?

  2. Per-poly XZ AABB cache for find_containing_poly_local.
  Compute once at parse time alongside neighbour adjacency. Localize currently does point-in-convex on every poly of every passing island. With cached AABBs, it short-circuits ~90 % of poly tests
   cheaply. No algorithmic change, just early reject.
  3. Surface raycast / LOS shortcut — dtNavMeshQuery::raycast shape.
  Walks polys along a 2D line from start to goal, returns "no obstruction" if you can see straight through. When it succeeds, skip A* entirely and emit [start, goal] directly. Cheapest path
  possible when applicable, which on flat plazas is most paths. ~80 LOC.
  4. Closest-point-on-poly with height — dtNavMeshQuery::closestPointOnPoly.
  Today _localize ignores Y entirely. Adding a "snap goal to nearest poly point with the poly's Y" gives accurate Y at endpoints even without a full detail mesh. Critical when Phase 2 terrain
  lands but already useful for any sloped polygon.
  5. dtQueryFilter-style area costs — read the high 4 bits of t_nvm_polygon::flags we currently ignore.
  Even one area type beyond default (e.g. "road" with cost 0.7×, "mud" with cost 2×) makes spline-vs-plaza preference expressible without architecture changes. Stop wasting the bits we already
  serialise.


  Tier 2 — when Phase 2/3 lands

  6. Polymesh detail (rcBuildPolyMeshDetail) — Y-accurate getPolyHeight(x,z).
  Pointless on flat pubs, mandatory once nav_terrain introduces ramps and stairs. Either delete the dead detail_sample_dist params now or keep them and finally call rcBuildPolyMeshDetail + ship
  the height samples in the .nvm (extend the format with one section). Don't leave them dead.
  7. Generic off-mesh connections beyond doors — Detour-style point-to-point links with a "side" (mono/bi-directional).
  Your t_nav_passage_edge is already an off-mesh edge in disguise. Generalise create_passage to take a (point_a, point_b, bidir) triple and gate it with the same /is_nav_connector mechanism. Buys
   ladders, balcony drops, jump-down spots, fence-hop points without further plumbing.
  8. Convex-volume area paint at bake time — Recast's rcMarkConvexPolyArea.
  Lets level authors paint cost regions (e.g. "the muddy yard near the stables", "the stage area is off-limits during performances") into the heightfield before rcBuildRegions. Pairs with (5).
  9. moveAlongSurface at the locomotion layer.
  Not a planner feature — a runtime helper that takes a desired pos and returns the constrained pos clamped to the navmesh, sliding along walls. Massively improves robustness when an actor's RVO
  impulse pushes them off the mesh edge. Needed once crowds get dense.
  10. findStraightPath per-waypoint flags — Detour returns DT_STRAIGHTPATH_OFFMESH_CONNECTION / DT_STRAIGHTPATH_END per waypoint.

  Tier 3 — when scale demands it

  11. BVTree per island — Detour's dtMeshTile::bvTree.
  O(log P) localize via tree descent. Worth it past ~1 K polys/island or when ~50+ islands are loaded. Phase 1 is below that.
  12. findRandomPointAroundCircle / findRandomPoint — for wander/stroll target selection.
  Today your behaviours probably pick a target via env-grid or symbolic kind, then ask the planner to reach it. A native "give me a walkable point in radius R that has a route from here" call
  removes a fail-and-replan round trip when the symbolic target lands on an unreachable poly.
  13. dtPathCorridor-style live corridor maintenance.
  Detour treats the path as a "corridor" of polyRefs and re-tightens it as the actor moves: optimizePathTopology, optimizePathVisibility. Your version-snapshot revalidation handles passage flips
  but doesn't compress the remaining path as obstacles are passed. Useful once paths are long enough that mid-route shortcuts matter — probably with nav_spline in Phase 3.
  14. Recast's monotone region partitioning — alternative to watershed.
  Faster bake (~3-5×), less optimal regions. Only relevant if bake time hurts in the editor; today it doesn't.

  While you're in there:
  - Delete dead detail_sample_dist / detail_sample_max_error params + the t_rc_polymeshdetail_deleter struct (or use them per Tier-2 item 6).
  - Name the magic numbers (0xFFFFu poly/edge sentinels, 1e-3f A* stale eps).
  - Fold k_anchor_max_xz_dist_m and k_nav_localize_tolerance_m into one constant — the comment at nav_mesh.h:88-91 promises they agree; let the code enforce it.
  - Dedupe the sliver-detector (currently implemented twice — once in navmesh_bake.cpp, once in nav_mesh.cc).
  - Strike the three factually-wrong objections to Detour from nav_v2_plan.md §3.5 and replace them with the actual reason: "Phase 1 ships a working from-scratch implementation; Detour features
  are cherry-picked as needed."






● SWE Rivers in GRYM — Investigation Report

  What Crimson Desert actually does

  Their published-talk approach is a 2D Shallow Water Equation solver on a heightfield grid (water column h, momentum hu, hv), running fully on GPU. The bed is the terrain heightmap; water fills basins,
   flows downhill, interacts both ways with NPCs/objects (current pushes them; they push water). Typically implemented either as direct SWE with a stable explicit scheme (Lax-Friedrichs / MacCormack) or
   — more commonly in production — the Virtual Pipes approximation (Mei/Decaudin/Neyret '07): per-cell outflow fluxes through 4 "pipes" to neighbors. Virtual Pipes is what most shipping games use; it's
  unconditionally stable when fluxes are clamped by available volume.

  What GRYM already has that we can lean on

  Rivers as splines (already in tree): Engine/Components/RiverComponent.h defines t_river_component + t_river_node_component (per-node width), with k_auto_flow_map deriving flow direction from spline
  tangent. wiRiver.cpp builds a ribbon mesh by walking the spline. Today it's pure geometry with scrolling normal maps — no simulation. The authoring side is done.

  Terrain heightfield: unified R16 heightmapGPU (4096² default), texel scale is terrain_unit_size. GPU helpers in Engine/shaders/ShaderInterop_Terrain.h:119-193 (terrain_world_to_local,
  terrain_local_to_uv, terrain_sample_world_height). CPU side: GetHeightAtWorldPos() in wiTerrain.cpp:1535. The bed is already there.

  GPU sim infrastructure: Ocean2 cascades (ocean2SimulatorCS/DisplacementCS/GradientFoldingCS) demonstrate the full pattern — async-compute dispatch, ping-pong textures, GPU→CPU readback for CPU
  queries. Scene::GetOceanPosAt() (wiScene.cpp:7714) is the readback API we'd mirror for SWE.

  Cache invalidation precedent: EnsureHeightmapGPU() + InvalidateCellCache() pattern (your recent grass-scatter fix) is the exact model for keeping a SWE bed-texture in sync with terrain edits.

  Physics force injection: wiPhysics_Jolt.cpp:2857 adds wind to soft bodies via body_interface.AddForce(...). Current would use the same call against rigid bodies & character controllers. No per-frame
  environmental-force pass exists for characters yet — that's a new system_pass.

  Recommended approach

  Solver: Virtual Pipes, not direct SWE. Per-cell state = (h, fL, fR, fU, fD) — water column + 4 outflow fluxes. Two CS passes per substep: (1) flux update from height gradient with volume clamping, (2)
   height update from net flux. Velocity (hu, hv) derived from fluxes for visuals and current force. Stable without CFL micro-stepping, simple code, well-mapped to GRYM's existing dispatch idioms.

  Domain: clipmap-style around camera (like terrain/grass) rather than world-spanning. 2-3 levels, each 512²–1024², gives kilometers of coverage at ~48 MB and ~1-2 ms compute. Lakes outside the clipmap
  keep their static authored height; only the active ring runs the simulation.

  Sources/sinks from splines: first node of each river spline becomes a volumetric inflow (m³/s); the spline polyline rasterizes velocity hints into the initial (hu,hv) field so rivers seed flow
  direction. Boundary with Ocean2 is a pinned-height Dirichlet condition where the SWE clipmap intersects ocean.

  NPC coupling (both directions):
  - Water → NPC: GPU readback texture (GetWaterStateAt(pos) → {height, velocity, depth}) following the GetOceanPosAt pattern. Per-frame water_system::run() iterates character/rigid bodies, applies drag
  + buoyancy + current via AddForce/SetLinearVelocity.
  - NPC → water: a small CS that scatter-writes velocity impulses into the SWE grid at body positions each frame. Cheap (hundreds of bodies, point splats).

  Rendering: keep the projected-grid VS pattern from ocean2SurfaceVS.hlsl, but sample displacement from the SWE height texture instead of FFT cascades. Layer one or two short-wavelength FFT cascades on
  top for surface ripple. Foam from |∇·v| and velocity magnitude. The current ribbon-mesh river path becomes the fallback for splines flagged "static" — simulated rivers replace the ribbon with the
  projected grid clipped to their footprint.

  Phase plan

  1. SWE solver in isolation — new wiWaterSim.h/cpp + waterSim*.hlsl, runs on a fixed test grid with hand-authored bed, no engine integration. Verify stability, dam-break, lake-fill.
  2. Terrain bed integration — clipmap centered on camera, sample heightmapGPU for bed. Spline inflows. Hook reconciliation to terrain edits (mirror EnsureHeightmapGPU flow).
  3. Render integration — projected-grid sampling SWE texture, foam, optional FFT-ripple overlay. Wire into RiverComponent as a flag.
  4. Readback + physics coupling — GetWaterStateAt, new water_system::run() applying forces.
  5. NPC → water displacement — scatter CS, splash particles tied to velocity-injection magnitude.
  6. Ocean boundary, wetness/substrate feedback — couple to existing moisture substrate so wading paints wet trails (you already invalidate grass on moisture edits — the loop closes).

  Open decisions before I'd start writing code

  - Clipmap vs world-spanning (clipmap is my recommendation, but pinned lakes need a story).
  - Render-side: replace ribbon entirely for simulated rivers, or composite SWE displacement onto the ribbon mesh?
  - NPC count target — drives whether readback is per-body CPU or a GPU-side query buffer.
  - Whether wetness/substrate writeback is in scope for v1 or follow-up.

  Net: GRYM is well-positioned. The river/spline authoring, terrain heightfield access, GPU sim infrastructure, and readback pattern all already exist. The new code is the SWE solver, the projected-grid
   water shader, and a water_system for physics coupling — maybe 1500–2000 LOC across ~6 files plus shaders. The riskiest part isn't the solver; it's the boundary conditions (ocean interface, clipmap
  ring scrolling) and getting per-NPC physics coupling fast enough.
