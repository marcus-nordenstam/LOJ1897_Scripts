
# Put.mc - inverse of Take. The actor places ?thing (which one of @self's
# hands controls) into a put_cell that the task claims and stashes on its
# private blackboard.
#
# Lifecycle (mirrors Take):
#   1. Claim a put_cell once and write it to the task's private bb.
#   2. LEFT_REACH_FOR or RIGHT_REACH_FOR the cell, depending on which hand
#      controls ?thing.
#   3. On reach success, fire LEFT_UNGRASP or RIGHT_UNGRASP. UNGRASP detaches
#      ?thing from the hand socket, makes it root, restores visibility +
#      ground-collision, releases the controlledBy attr, and snaps ?thing's
#      world position to the put_cell carried as the action's auxiliary arg.
#   4. Outcome rules propagate UNGRASP's outcome to the put task. A separate
#      release rule unclaims the cell and clears the bb whenever the put
#      task has an outcome - covers normal success and external interrupts.

# Phase 1: claim the put_cell once. (env_cell_size ?thing) picks the level
# that fits the thing being placed; (des on_top_of ?surface) constrains the
# search to cells resting on ?surface's top surface.
rule put-claim-cell
{@self put ?thing ?surface}: ?put
{@self hand ?hand}
{?hand control ?thing}
(bb_private_none ?put put_cell)
(claim_env_cell (env_cell_size ?thing) (des on_top_of ?surface)): ?put_cell
    ->
(bb_private_write ?put put_cell ?put_cell).

# Phase 2 (left): reach the left hand toward the put_cell.
rule put-left-reach-for-proposal
{@self put ?thing ?surface}: ?put
{@self hand [k left_hand]:?hand}
{?hand control ?thing}
(bb_private_read ?put put_cell): ?put_cell
    ->
(maintain_proposal {@self LOOK_AT ?put_cell} (des abs_util 2000))
(maintain_proposal {@self TURN_TO ?put_cell} (des abs_util 2000))
(maintain_proposal {@self LEFT_REACH_FOR ?put_cell} (des abs_util 2000)).

# Phase 2 (right): symmetric.
rule put-right-reach-for-proposal
{@self put ?thing ?surface}: ?put
{@self hand [k right_hand]:?hand}
{?hand control ?thing}
(bb_private_read ?put put_cell): ?put_cell
    ->
(maintain_proposal {@self LOOK_AT ?put_cell} (des abs_util 2000))
(maintain_proposal {@self TURN_TO ?put_cell} (des abs_util 2000))
(maintain_proposal {@self RIGHT_REACH_FOR ?put_cell} (des abs_util 2000)).

# Phase 3 (left): once the reach has succeeded, ungrasp. The put_cell is
# passed as the action's auxiliary so the C++ handler positions ?thing at
# the cell the rule reasoned about (not at the hand's instantaneous pose).
# bb_private_read binds ?put_cell FIRST so the LEFT_REACH_FOR pattern is
# constrained to the put_cell - otherwise the pattern would match any
# successful reach the actor has ever done (e.g. an earlier umbrella reach)
# and ?put_cell would be bound to that wrong target.
rule put-left-ungrasp-proposal
{@self put ?thing ?surface}: ?put
{@self LEFT_REACH_FOR ?put_cell /succ /causes ~?put}
{@self hand [k left_hand]:?hand}
{?hand control ?thing}
(bb_private_read ?put put_cell)
    ->
(begin_proposal {@self LEFT_UNGRASP ?thing ?put_cell} (des abs_util 2000)).

# Phase 3 (right): symmetric.
rule put-right-ungrasp-proposal
{@self put ?thing ?surface}: ?put
{@self RIGHT_REACH_FOR ?put_cell /succ /causes ~?put}
{@self hand [k right_hand]:?hand}
{?hand control ?thing}
(bb_private_read ?put put_cell)
    ->
(begin_proposal {@self RIGHT_UNGRASP ?thing ?put_cell} (des abs_util 2000)).

# Outcome (left): propagate LEFT_UNGRASP's outcome to the put task.
rule put-left-outcome
{@self /ever put ?thing ?surface /no_out}: ?put
{@self /past LEFT_UNGRASP ?thing ? /causes ~?put /out?}: ?UNGRASP
    ->
(unclaim_env_cell (bb_private_read ?put put_cell))
(bb_private_clear ?put put_cell)
(set_outcome ?put (outcome ?UNGRASP)).

# Outcome (right): symmetric.
rule put-right-outcome
{@self /ever put ?thing ?surface /no_out}: ?put
{@self /past RIGHT_UNGRASP ?thing ? /causes ~?put /out?}: ?UNGRASP
    ->
(unclaim_env_cell (bb_private_read ?put put_cell))
(bb_private_clear ?put put_cell)
(set_outcome ?put (outcome ?UNGRASP)).
