
# Put.mc - inverse of Take. The actor places ?thing (which one of @self's
# hands controls) into a put_cell that the task claims and stashes on its
# private blackboard.
#
# Lifecycle (mirrors Take):
#   1. Claim a put_cell once and write it to the task's private bb.
#   2. REACH_FOR (sided) the cell with the hand that controls ?thing.
#   3. On reach success, fire UNGRASP. UNGRASP is sided on its target slot
#      (target = the hand kind, side-bearing); the handler derives the held
#      thing from the hand's control attr, detaches it from the hand socket,
#      makes it root, restores visibility + ground-collision, releases the
#      controlledBy attr, and snaps the thing's world position to the put_cell
#      carried as the action's auxiliary arg.
#   4. The outcome rule propagates UNGRASP's outcome to the put task and
#      releases the claimed cell (covers normal success and external interrupts).

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

# Phase 2: reach the controlling hand toward the put_cell. REACH_FOR is sided
# -- (side ?hand) feeds the action_side_field=aux slot and Ontology::motor_bits
# resolves the engaged arm motor at install time.
rule put-reach-for-proposal
{@self put ?thing ?surface}: ?put
{@self hand ?hand}
{?hand control ?thing}
(bb_private_read ?put put_cell): ?put_cell
    ->
(maintain_proposal {@self LOOK_AT ?put_cell} (des abs_util 2000))
(maintain_proposal {@self TURN_TO ?put_cell} (des abs_util 2000))
(maintain_proposal {@self REACH_FOR ?put_cell (side ?hand)} (des abs_util 2000)).

# Phase 3: once the reach has succeeded, ungrasp. UNGRASP is sided on its
# target slot - target = ?hand (the side-bearing kind). The put_cell is passed
# as the action's auxiliary so the C++ handler positions ?thing at the cell
# the rule reasoned about (not at the hand's instantaneous pose).
# bb_private_read binds ?put_cell FIRST so the REACH_FOR pattern is constrained
# to the put_cell - otherwise the pattern would match any successful reach the
# actor has ever done (e.g. an earlier umbrella reach) and ?put_cell would be
# bound to that wrong target.
rule put-ungrasp-proposal
{@self put ?thing ?surface}: ?put
{@self REACH_FOR ?put_cell /succ /causes ~?put}
{@self hand ?hand}
{?hand control ?thing}
(eq (bb_private_read ?put put_cell) ?put_cell)
    ->
(begin_proposal {@self UNGRASP ?hand ?put_cell} (des abs_util 2000)).

# Outcome: propagate UNGRASP's outcome to the put task and release the claimed
# cell. The hand slot is wildcarded since the task doesn't care which hand did
# the release - it cares that the right thing went to the right cell.
rule put-outcome
{@self /ever put ?thing ?surface /no_out}: ?put
{@self /past UNGRASP ? ? /causes ~?put /out?}: ?UNGRASP
    ->
(unclaim_env_cell (bb_private_read ?put put_cell))
(bb_private_clear ?put put_cell)
(set_outcome ?put (outcome ?UNGRASP)).
