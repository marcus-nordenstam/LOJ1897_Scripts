

# Phase 1: Propose reach-for (the handler determines when the hand arrives)

# If you're too far away, get closer
rule take-move-closer
{@self take ?thing}
(in_range /reach /not ?thing 0.5 (des stay_at 0.3) /debug)
    ->
(maintain_proposal {@self go_entity ?thing} (des abs_util 2000)).


rule take-left-reach-for-proposal
{@self take ?thing}
{@self hand [k left_hand]:?hand}
{?hand control _}
(in_range /reach ?thing 0.5 (des stay_at 0.3) /debug)
(lockRule take 0)
    ->
(maintain_proposal {@self LOOK_AT ?thing} (des abs_util 2000))
(maintain_proposal {@self TURN_TO ?thing} (des abs_util 2000))
(maintain_proposal {@self LEFT_REACH_FOR ?thing} (des abs_util 2000)).

rule take-right-reach-for-proposal
{@self take ?thing}
{@self hand [k right_hand]:?hand}
{?hand control _}
(in_range /reach ?thing 0.5 (des stay_at 0.3) /debug)
(lockRule take 1) # prefer right-hand
    ->
(maintain_proposal {@self LOOK_AT ?thing} (des abs_util 2000))
(maintain_proposal {@self TURN_TO ?thing} (des abs_util 2000))
(maintain_proposal {@self RIGHT_REACH_FOR ?thing} (des abs_util 2000)).

# Phase 2: If the reach was successful, propose GRASP (to control it)

rule take-left-grasp-proposal
{@self take ?thing}
{@self LEFT_REACH_FOR ?thing /succ}
    ->
(begin_proposal {@self LEFT_GRASP ?thing} (des abs_util 2000)).

rule take-right-grasp-proposal
{@self take ?thing}
{@self RIGHT_REACH_FOR ?thing /succ}
    ->
(begin_proposal {@self RIGHT_GRASP ?thing} (des abs_util 2000)).

# Outcome: succeed when the hand controls the thing
rule take-left-outcome
{@self /ever take ?thing /noOut}: ?take
{@self /past LEFT_GRASP ?thing /causes ~?take /out?}: ?GRASP
    ->
(set_outcome ?take (outcome ?GRASP)).

rule take-right-outcome
{@self /ever take ?thing /noOut}: ?take
{@self /past RIGHT_GRASP ?thing /causes ~?take /out?}: ?GRASP
    ->
(set_outcome ?take (outcome ?GRASP)).



rule left-hand-control-LEFT_ARM_OUT-proposal
{@self hand [k left_hand]:?hand}
{?hand control @something}
    -> /cont
(maintain_proposal {@self LEFT_ARM_OUT}).

rule right-hand-control-RIGHT_ARM_OUT-proposal
{@self hand [k right_hand]:?hand}
{?hand control @something}
    -> /cont
(maintain_proposal {@self RIGHT_ARM_OUT}).

