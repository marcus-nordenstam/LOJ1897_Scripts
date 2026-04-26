

rule get-maintain-within_reach_of-proposal
{@self get ?thing}
    ->
(maintainProposal {@self keep_near_and_facing ?thing} (abs_util 1000)).

rule get-take-proposal
{@self get ?thing}
{?thing obb !@unknown}
{@self within_reach_of ?thing}
{@self facing ?thing}
(real ?thing)
    ->
(maintainProposal {@self take ?thing}).


# Base the activity's outcome on the corresponding take task's outcome
rule get-outcome
{@self /ever get ?thing /noOut}: ?get
{@self /past take ?thing /causes ~?get}: ?take
    ->
(setOutcome ?get (outcome ?take)).

/*
rule 
{/prop @self TAKE ?thing ?freeHand}: ?TAKE
{?freeHand isa [k left_hand]}
    ->
(penalize ?TAKE 1).

rule 
{/prop @self TAKE ?thing ?freeHand}: ?TAKE
    ->
(penalize ?TAKE (distance @self ?thing)).
*/