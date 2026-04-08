

# Phase 1: Propose reach-for (the handler determines when the hand arrives)

rule take-left-reach-for-proposal
{@self take ?thing}
{@self hand [k leftHand]:?hand}
{?hand control @nothing}
(lockRule take 0)
    ->
(maintainProposal {@self LOOK_AT ?thing} /absUtil 1000)
(maintainProposal {@self TURN_TO ?thing} /absUtil 1000)
(maintainProposal {@self LEFT_REACH_FOR ?thing} /absUtil 1000).

rule take-right-reach-for-proposal
{@self take ?thing}
{@self hand [k rightHand]:?hand}
{?hand control @nothing}
(lockRule take 1) # prefer right-hand
    ->
(maintainProposal {@self LOOK_AT ?thing} /absUtil 1000)
(maintainProposal {@self TURN_TO ?thing} /absUtil 1000)
(maintainProposal {@self RIGHT_REACH_FOR ?thing} /absUtil 1000).

# Phase 2: If the reach was successful, propose GRASP (to control it)

rule take-left-grasp-proposal
{@self take ?thing}
{@self LEFT_REACH_FOR ?thing /succ}
    ->
(beginProposal {@self LEFT_GRASP ?thing} /absUtil 1000).

rule take-right-grasp-proposal
{@self take ?thing}
{@self RIGHT_REACH_FOR ?thing /succ}
    ->
(beginProposal {@self RIGHT_GRASP ?thing} /absUtil 1000).

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
{@self hand [k leftHand]:?hand}
{?hand control @something}
    ->
(maintainProposal /cont {@self LEFT_ARM_OUT}).

rule right-hand-control-RIGHT_ARM_OUT-proposal
{@self hand [k rightHand]:?hand}
{?hand control @something}
    ->
(maintainProposal /cont {@self RIGHT_ARM_OUT}).

