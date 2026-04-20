

# Phase 1: Propose reach-for (the handler determines when the hand arrives)

# If you're too far away, get closer
rule take-move-closer
{@self take ?thing}
(in_range /reach /not ?thing 0.5 /stay_at 0.3 /dist_debug)
    ->
(maintainProposal {@self go_entity ?thing} /absUtil 2000).


rule take-left-reach-for-proposal
{@self take ?thing}
{@self hand [k left_hand]:?hand}
{?hand control @nothing}
(in_range /reach ?thing 0.5 /stay_at 0.3 /dist_debug)
(lockRule take 0)
    ->
(maintainProposal {@self LOOK_AT ?thing} /absUtil 2000)
(maintainProposal {@self TURN_TO ?thing} /absUtil 2000)
(maintainProposal {@self LEFT_REACH_FOR ?thing} /absUtil 2000).

rule take-right-reach-for-proposal
{@self take ?thing}
{@self hand [k right_hand]:?hand}
{?hand control @nothing}
(in_range /reach ?thing 0.5 /stay_at 0.3 /dist_debug)
(lockRule take 1) # prefer right-hand
    ->
(maintainProposal {@self LOOK_AT ?thing} /absUtil 2000)
(maintainProposal {@self TURN_TO ?thing} /absUtil 2000)
(maintainProposal {@self RIGHT_REACH_FOR ?thing} /absUtil 2000).

# Phase 2: If the reach was successful, propose GRASP (to control it)

rule take-left-grasp-proposal
{@self take ?thing}
{@self LEFT_REACH_FOR ?thing /succ}
    ->
(beginProposal {@self LEFT_GRASP ?thing} /absUtil 2000).

rule take-right-grasp-proposal
{@self take ?thing}
{@self RIGHT_REACH_FOR ?thing /succ}
    ->
(beginProposal {@self RIGHT_GRASP ?thing} /absUtil 2000).

# Outcome: succeed when the hand controls the thing
rule take-left-outcome
{@self /ever take ?thing /noOut}: ?take
{@self /past LEFT_GRASP ?thing /causes ~?take /out?}: ?GRASP
    ->
(setOutcome ?take /from ?GRASP).

rule take-right-outcome
{@self /ever take ?thing /noOut}: ?take
{@self /past RIGHT_GRASP ?thing /causes ~?take /out?}: ?GRASP
    ->
(setOutcome ?take /from ?GRASP).



rule left-hand-control-LEFT_ARM_OUT-proposal
{@self hand [k left_hand]:?hand}
{?hand control @something}
    ->
(maintainProposal {@self LEFT_ARM_OUT}).

rule right-hand-control-RIGHT_ARM_OUT-proposal
{@self hand [k right_hand]:?hand}
{?hand control @something}
    ->
(maintainProposal {@self RIGHT_ARM_OUT}).

