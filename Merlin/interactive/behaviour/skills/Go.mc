/*
1. Containment
Any entity with an OBB has spatial-bounds.  And spatial-bounds can always be used to query if something is "in"
the spatial bounds.  This is true of spaces, structures, and all other entity archetype with a spatial-bounds attr, 
including (of course) container_structures.
We formally say that an entity C contains a point x if x is inside C's spatial bounds
Likewise any obb is inside C if obb is inside C's spatial bounds.
We define a SINGLE SOURCE OF TRUTH for such containment queries, namely env.contains().
These functions must be used by ALL call-sites that query containment of of points, obbs, etc., regardless of the
kind of entity acting as 'container'.
HOWEVER: While spaces may overlap or nest, container_stuctures may NOT overlap or nest.  This must be a guarantee in both
world-design / input data, and the architecture and c++ logic.  We should issue hard errors if this is ever violated
in input or output.  Also it would not make any sense, since unlike spaces which have no physical boundaries, a 
container_structure has a PHYSICAL boundary (with openings), and physical boundaries cannot physically overlap.
While they COULD in theory nest, we simply won't allow that in our game world.

2. The world grid
The world is not a container or entity, but it has an absolute env-grid of env-cells so that pathfinding and occupancy
is possible to describe and for NPCs to reason about when outside any container.

3. Container grids
Here is where the big distinction between general entities with spatial bounds occurs vs container_structures specifically:
Only container_structures are capable of generating their own local env-grids that can hold occupancy etc., and be used
for container-local pathfinding, object placements, etc.  Since container_structures are themselves entities, and have
their own OBB, any container_structure may be arbitrarily oriented, not necessarily along world-space axes.  That's fine,
since their env-grid is defined in the constainer_structure's local space, and thus axis-aligned locally.
Unlike containment, the env-grids of different containers MAY overlap (and even nest, though unlikely).
This is because two buildings may be very close to each other, but as long as their containment doesn't overlap, 
we'll still only get ONE container per cell in terms of containment query.  Having padding around the spatial bounds is
quite useful because it means an NPC standing right next to the building, or at an entrance or opening, but strictly 
outside its bounds, can still A* pathfind on the building grid from its own position with no special handling.

3. Reasoning & pathfinding

When NPCs want to enter a building, they will first WALK_TO the entrance of that building.  The entrance is either 
an explicit space-entity part of the container_structure (e.g. the building), or an env-cell just outside the building's 
opening space.  Either way, the competion of that WALK_TO will put the NPC in a cell that is part of the building's env-grid,
yet still uncontained by the building's spatial bounds.  Now the NPC can pathfind from their position on the building's 
local grid - no issues.

Likewise, when an NPC is going to exit a building, they just need to walk to that same cell: a cell in an 
explicit entrance space, or a cell in front of the building's opening.  Either way it will be a cell that is outside
the building's bounds, yet still mappable on the building's grid.  So the NPC can pathfind to that 'exit cell' completely
on the building's grid.  Once there, they are outside the building, and can then just start pathfinding to some world-cell
on the world-grid.

An NPC on a moving-train, trying to exit train-car A and go to train-car B works out as follows:
* WALK_TO A's entrace-cell (outside A but still on A's grid, so local pathfind).  
* Next, WALK_TO B's entrance cell (outside B but on B's grid).  This is technically a world-pathfind, since both
  start and end are outside any containers, despite the fact that both start/end are in container grids.
* Then, WALK_TO x (where x is some location inside B, which of course is also on B's grid, so it's a local pathfind).

4.  Robustness and error handling

Now we can simply error and abort actions where start/end are CONTAINED by different containers or world/container mismatch.
Error detection becomes very simple.  Only world/world, or same-container pathfinding-pairs are valid.  The above setup
guarantees all the valid movement combinations will work.

5. Padding.

For this to work, all container_structures must ensure there is at least 1 whole chunk of padding surrounding the 
container_structure's spatial-bounds AND all its child parts (some of which may protrude beyond its spatial bounds, 
such as an entrance space, or some openings).













 A. Headline finding — container env-grids are non-functional

  The cell-encoding (EnvCell.h) and pathfinder (EnvPathFinder.cc) have full container-branch plumbing, but the rasterizer, the rule-function search, and the C interface all treat every chunk as a world chunk. Net effect: NPCs inside a building A*
  through unrasterized container chunks and walk straight through walls.

  The user's high-level design (sec. 3, "Container grids") is therefore not actually implemented today. Concrete evidence:

  1. Environment::_populateStaticArrayForChunk (Environment.cc:1159-1269) ignores chunkKey.container_id. Container chunks compute chunkMinX = chunkKey.cx_abs * chunkDimXZ and call sectorGrid.adjSectorIndices4(...) at that "world" position. For
  container cells, cx_abs is a local index, so the rasterizer scans world entities at a meaningless world position and stamps them into the container chunk. Result: container chunks have garbage statics (or nothing), not the building's parts.
  2. Environment::_appendMovablesToChunks (Environment.cc:1389-1410) iterates only at world chunk indices and uses EnvChunkKey{cx, cy, cz} (default container_id=0). NPCs are never rasterized into container chunks — so container-space A* sees no other
   NPCs.
  3. env_find_best_cell / env_find_nearest_cell (EnvCellQuery.h:154) uses EnvChunkKey key{cx, cy, cz} with default container_id 0 throughout. So claim_env_cell and env_cell_occupier never produce container cells — the rule layer always picks world
  cells, even when the reference entity is inside a building. (The architectural intent — claiming a cell on a bar counter inside a pub via the pub's local grid — is not realised.)
  4. mx_env_cell_world_pos (mx_env.cc:315-320) calls env_cell_to_world(coords) directly. For container cells, that returns local coords — WALK_TO would steer toward the wrong world position. Same bug in mx_world_bounds (mx_env.cc:44-53) and
  Environment::tryGetLocalObb (Environment.h:156-164) and initOBB in Sensors/Util.h:72-82. (Today these don't manifest because nothing produces container cells outside the pathfinder's internal search.)
  5. world_to_container_env_cell (EnvCell.h:317) writes raw chunk_ax/cy/cz into int16_t fields, but env_cell_pack truncates the container branch to 8 bits for cx/cz and 9 bits for cy. So if start or goal lies more than ~128 chunks (~150m at L1)
  outside the container's local origin, the encoded cell wraps around silently. WALK_TO from a far-away world position to a building goal would produce a corrupt start cell.
  6. advance_cell_by (EnvPathFinder.cc:48-68) re-decomposes coords through chunks_per_sector/sx, which only makes sense for world cells. It preserves c = from (so container_id is kept), but then overwrites c.sx/c.sz from sector math even for
  container cells. For any container cell crossing chunk boundaries, the resulting cx/cz values are wrong. The (uint8_t) casts on line 63-66 are also wrong for the world branch (cx/cz are 6-bit unsigned 0..63, fine; but for container 8-bit signed cx,
   the cast destroys negatives).
  7. The cross-container error path in request_path (EnvPathFinder.cc:678-689) is the only safety net: it fails requests whose start and goal containers differ. The rule layer (Go.mc) never decomposes journeys into per-container WALK_TO legs as the
  design comment promises — go-entity-walk-to-proposal just calls WALK_TO ?obb and the retry rule waits 120 cycles between failures and retries 10 times, which won't help a cross-container failure.

  B. Pathfinder bugs

  8. Pathfinder slot leak on entity death. Population::destroyEntity (Population.cc:374) calls unclaimAllForEntity but never tells pathFinder about the death. EnvPathFinder::_per_actor keeps the dead actor's slot, _result_pool never frees it, and
  update() continues to refresh lastRequestedCycle on the dead actor's path_chunks (EnvPathFinder.cc:812-827), pinning chunks against expiry forever.

  ▎ Add pathFinder.cancel(entId, ...) plus _per_actor.erase and _result_pool.free in destroyEntity; or have update() purge entries whose actor no longer inUse().

  9. A* state is discarded between cycles. When _run_a_star runs out of per-cycle budget, it leaves state at k_env_path_pending and returns (EnvPathFinder.cc:530-532). Next cycle's call rebuilds open and visited from scratch — every long search
  restarts from the start cell every cycle. Burns CPU and prevents convergence on long paths under contention. The local open/visited need to be persisted on env_path_result, or per-search budget needs to be high enough that no real search ever
  pauses.
  10. Frontier emission is not gated. EnvPathFinder.cc:556-602 builds a std::vector<t_env_pathfind_frontier_entry>, fills it from visited, then calls MX_BLOG_ENV_PATHFIND_FRONTIER. The macro is no-op in shipping but the vector population code is not
  wrapped in #ifdef MX_BINLOG_ENABLED. Heap alloc + N*16-cell loops per failed path are wasted in shipping. Wrap the whole block.
  11. Goal collapse is 8-horizontal-only. EnvPathFinder.cc:249-281 checks the 8 neighbours of goal_cell for free static. If the goal lies on a wide static (counter, table top), all 8 neighbours are also static and goal-collapse silently leaves
  goal_cell unchanged → request fails as goal_blocked. Either widen to a small ring, or fail-and-let-rule-retry deliberately. Today the rule layer just retries the same request 10× then hard-fails.
  12. request_path cross-container error sets r->retries=0 but keeps the slot in _per_actor. Subsequent cancel(actor, expected_seq) after the error works because state is failed. Fine, but worth confirming when slot cleanup lands.
  13. Y-clamp uses world-Y deltas on container cells. EnvPathFinder.cc:719-734 snaps start to goal's y-layer using start.y - goal.y. For container cells the relevant Y is the container-local Y, not world Y. Works iff the container is upright (no
  pitch/roll); fragile by assumption.
  14. set_state_and_emit emits t_env_pathfind_outcome even for pending/working transitions. The renderer can filter, but it's a per-cycle event-spam in shipping if MX_BINLOG_ENABLED is on.
  15. mx_pathfind_request ignores invalid actor result. Returns 0 on error. WALK_TO IN-handler (WALK_TO.h:54) stores 0 into action.handler_seq without checking. Out-handler then calls mx_pathfind_cancel(actor, 0). Harmless but the pattern is fragile.

  C. Containment

  16. Environment::contains(EntityId, OBB) overload is wrong. Header comment (Environment.h:354) says "OBB-in-container containment. Pointwise containedBy test." Implementation calls MUtil::contains(worldObb, obb) (Environment.cc:870-877).
  MUtil::contains(OBB, OBB) (OBBAlgo.h:237-239) is volume>= && intersects, which is intersection, not containment. Reads true for any OBB even partly poking through. The function is currently dead (no callers) so this is silent rot, but it's a
  foot-gun named the same as the entity-vs-entity overload that uses correct containedBy.

  ▎ Either delete the OBB overload or fix it to call containedBy(worldObb, obb). While there, consider deleting MUtil::contains(OBB, OBB) outright — its semantics don't match its name and it has no current callers.

  17. register_container overlap check continues registering on overlap (Environment.cc:225-231). Comment says "the game will misbehave but we don't want to silently drop the entity" — but the design demands a hard error. At minimum, set a flag
  preventing the broken container from being used as a planContainer. Current behaviour: cross-container queries against a doubly-overlapping point return one of two arbitrarily.
  18. _containerKindResolved is a one-line cache without a lock (Environment.cc:262-269, :288-298, :301-310). For sequential deliberation (per audit scope) fine.
  19. enclosing_container_structure only walks subject's sector coverage. Works iff the container's OBB has been registered with the sector grid (it should be, via tryPlaceEntity), but if a container's OBB changes (drives across a sector boundary),
  the test relies on _broadcastEntityChanges's updateSectorCoverage having run earlier in the same cycle. That happens before pathFinder.update() in Environment::update, so OK — but the dependency is implicit.

  D. Env-grid / occupancy / claim lifecycle

  20. unclaimAllForEntity (EnvGrid.h:562-587) is O(total_chunks * cells_per_chunk) per entity destroy. Bounded (≤ 4096256 + 1024128 ≈ 1.2M), but worth batching destruction or maintaining a per-entity claim list if death frequency rises.
  21. HereMovables::append cap=128 (EnvGrid.h:60). At L1 a chunk is 9.6m × 9.6m × 9.6m. 128 entities in that volume is dense but plausible for a packed tavern; on overflow we drop the entity for that frame. Document that this is a soft fail and
  consider a small bump (256) — the per-chunk cost is ~2 KB extra.
  22. _clearMovableArrays's synthetic "cleared all" event uses local index 0xFFFF as a sentinel (Environment.cc:1325-1332). If chunks ever exceed 65535 cells, this collides. Currently safe (max 256 cells), but worth a static_assert.
  23. _storeCellAndLog compares prev.raw == entityId.raw (Environment.cc:1000-1008) but uses prev.raw rather than is_null/==. Works because EntityId defines equality by .raw. Minor — consistency with rest of code that uses EntityId{} and is_null
  would be cleaner.
  24. Phase (iv) AABB walk uses ground_height per chunk (Environment.cc:1381-1387) to derive cyMin/cyMax. ground_height() is hardcoded to 0 (EnvCell.h:127); fine today but every caller assumes flat ground. When terrain integration lands, this loop
  computes wrong cy ranges across slopes — flag as a known integration point.
  25. _applyStaticRepulsion is L1-only and world-only (Environment.cc:571-633). NPCs nudged by static occupancy don't get nudged off building walls (since container chunks have no proper statics). Consequence today: NPCs can lock into walls inside
  buildings.
  26. claim_env_cell (des at_or_near ?ent) with ?ent != @self: the kAdjacent self-exclusion is on @self's OBB regardless of the at_or_near anchor (EnvCellFunctions.h:325, :447-451, :557-561). Combined with the kSurrounding switch (:340), the
  exclusion is suppressed and behaviour is OK — but the wiring is non-obvious; a comment near line 447 would help.
  27. _resolveLevelFromEntityId returns 0 if k_grid_space_level_attr_id is missing (EnvCellFunctions.h:61-66). Population activation should auto-create that attr per architecture (per project_attr_refactor.md), but if it's ever missing the NPC
  silently picks L0 grid for claim_env_cell. Worth an MX_LOG_WARNING on the missing-attr path.
  28. Goal collapse uses a different distance metric than A* heuristic. Line 269 uses XZ Euclidean; A* uses octile. Rare 2nd-order issue: the picked neighbour may be octile-suboptimal but Euclidean-best.

  E. Stupid / fragile / duplicated code

  29. Two near-identical 64-line blocks for L0 vs L1 in EnvGrid.h::claimCell (:495-527) and unclaimCell (:535-556) and unclaimAllForEntity (:563-587). Templating on chunk-type would halve the file. The EnvSparseGrid<TChunk,TPool> template already
  exists, so factor claimCell/unclaimCell to operate on TChunk* and dispatch once at the top.
  30. Duplicated dispatch on container_id in EnvCell.h::env_cell_pack/env_cell_unpack/env_cell_to_world/env_cell_chunk_key/env_cell_from_chunk is necessary, but env_cell_to_world is named misleadingly: for container cells it returns local coords.
  Rename to env_cell_to_local and keep Environment::cell_to_world_pos as the only "world" variant. That one rename forces the bugs in items 4 & 5 to surface at compile time.
  31. Environment.cc:1170-1173 computes gy = ground_height(chunkMinX, chunkMinZ); chunkMinY = gy + chunkKey.cy * chunkDimY. But the doc in EnvCell.h:264-265 says "cy is now ABSOLUTE, no longer ground-relative". The rasterizer is still adding
  ground_height to its per-chunk Y origin — inconsistent. Today ground_height==0 so no symptom, but when terrain lands, statics rasterize at gy + cy*dy while world_to_env_cell quantizes at cy*dy directly. Fix: drop the gy + everywhere in the
  rasterize/append paths.
  32. Environment::loadTerrain and makeFlatWorld both call envGrid.init() and pathFinder.init(&envGrid) (Environment.cc:151-152, :201-202). If either is called twice (e.g., scene reload), pools are re-init'd in place; SlabPool may not handle this
  cleanly. Worth a _alreadyInitialized guard.
  33. Environment.cc:153-155 has a commented-out MX_LOG_DEBUG. Delete or rewrite.
  34. EnvPathFinder.cc:73-84 constants all use kEnvPath... but the current code uses snake_case_k convention (per coding rules). New constants should be k_env_path_max_expansions etc. Cosmetic. Same for kEnvShellMarginFactor, kEnvMinPenetration, etc.
   — they predate the snake_case migration and are scattered around EnvCell.h and EnvGrid.h.
  35. EnvPathFinder.cc:213-227 the sentinel EnvChunkKey{INT32_MIN, INT32_MIN, INT32_MIN} matches a chunk only if cx_abs == INT32_MIN, which is impossible in practice but inelegant. Add bool initialised = false to the comparison.
  36. mx_pathfind.cc:52-61 comment says "any other state may have in-flight writes from a worker" — the current code is single-threaded, so this is stale. Keep the acquire-load (the discipline is still correct), but update the comment.
  37. WALK_TO.h:9 kWalkToRepathDistSq: at 1.0f * 1.0f, NPC re-requests on every >1m goal drift. Each re-request calls _run_a_star afresh and discards the prior search state (item 9). For a moving target like an NPC walking around, this can starve the
   pursuer. Hysteresis (different threshold to start vs stay) would match the in_range pattern already used elsewhere.

  F. Dead code / wrong comments

  38. Environment::contains(EntityId, OBB) — dead, see item 16.
  39. mx_pathfind_advance removal note in mx_pathfind.h:73-77 should be a git commit message, not a permanent comment per project rule "Don't add migration-history in comments".
  40. EnvPathFinder.h:5-27 comment block still mentions "worker-pool" in places it shouldn't (e.g. memory in project_env_pathfinder.md is stale). The file says "All work runs serially on the main thread" up top, but then EnvRequestBuffer comment at
  EnvGrid.h:177-181 says "Multiple deliberation threads (and pathfinder, when MT) append concurrently". Decide on one story.


*/





# NOTE that going to and locating documents must be done differently
# since documents are in stacks; so these rules only apply for non-documents destinations.




# We must now change the rules a bit:

# If you're going to an entity inside a container_structure, 
# and you are NOT inside it right now, then you must first go to the opening closest to you

# If you are at the opening of the container_structure that contains the destination
# then go to the entity in the container_structure.


# define an irregular shaped container, so we can know 
# if something is inside or outside it.


# These are general go-to-entity rules

rule go-entity-locate-proposal
{@self go_entity ?dest} 
{?dest obb @unknown}
    ->
(maintain_proposal {@self locate ?dest}).

rule go-entity-walk-to-proposal
{@self go_entity ?dest}: ?go
{?dest obb !@unknown:?obb}
    ->
(bb_private_write ?go attempt 1)
(maintain_proposal {@self WALK_TO ?obb}).

rule go-entity-walk-to-retry
{@self go_entity ?dest}: ?go
{?dest obb !@unknown:?obb}
{@self WALK_TO ?obb /fail /causes ~?go}
(wait /cycles 120)
    ->
(bb_private_read ?go attempt): ?go_count
(bb_private_write ?go attempt (add ?go_count 1))
(if (lt ?go_count 10)
    (maintain_proposal {@self WALK_TO ?obb})
    (set_outcome ?go /fail)).

rule go-entity-outcome-success
{@self /ever go_entity ?dest /no_out}: ?go
{@self /succ WALK_TO ? /causes ~?go}
    ->
(set_outcome ?go /succ).

rule go-entity-outcome-interrupted
{@self /ever go_entity ?dest /no_out}: ?go
{@self /interrupt WALK_TO ? /causes ~?go}
    ->
(set_outcome ?go /interrupt).


# These are general go-to-env-cell rules

rule go-env-cell-walk-to-proposal
{@self go_env_cell ?env_cell}: ?go
    ->
(bb_private_write ?go attempt 1)
(maintain_proposal {@self WALK_TO ?env_cell}).

rule go-env-cell-walk-to-retry
{@self go_env_cell ?env_cell}: ?go
{@self WALK_TO ?env_cell /fail /causes ~?go}
(wait /cycles 120)
    ->
(bb_private_read ?go attempt): ?go_count
(bb_private_write ?go attempt (add ?go_count 1))
(if (lt ?go_count 10)
    (maintain_proposal {@self WALK_TO ?env_cell})
    (set_outcome ?go /fail)).

rule go-env-cell-interrupt
{@self /ever go_env_cell ?env_cell /no_out}: ?go
{@self /interrupt WALK_TO ?env_cell /causes ~?go}
    ->
(set_outcome ?go /interrupt).

rule go-env-cell-success
{@self /ever go_env_cell ?env_cell /no_out}: ?go
{@self /succ WALK_TO ?env_cell /causes ~?go}
    ->
(set_outcome ?go /succ).
