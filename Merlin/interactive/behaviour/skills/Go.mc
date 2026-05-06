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
