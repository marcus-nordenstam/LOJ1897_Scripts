

rule get-maintain-withinReachOf-proposal
{@self get ?thing}
    ->
(maintainProposal {@self keepInReachOf ?thing} /absUtil 1000)
(maintainProposal {@self keepFacing ?thing} /absUtil 1000).

rule get-take-proposal
{@self get ?thing}
{?thing obb !@unknown}
{@self withinReachOf ?thing}
{@self facing ?thing}
(real ?thing)
    ->
(maintainProposal {@self take ?thing}).


# Base the activity's outcome on the corresponding take task's outcome
rule get-outcome
{@self /ever get ?thing /noOut}: ?get
{@self /past take ?thing /causes ~?get}: ?take
    ->
(setOutcome ?get /from ?take).

/*
rule 
{/prop @self TAKE ?thing ?freeHand}: ?TAKE
{?freeHand isa [k leftHand]}
    ->
(penalize ?TAKE 1).

rule 
{/prop @self TAKE ?thing ?freeHand}: ?TAKE
    ->
(penalize ?TAKE (distance @self ?thing /cont)).
*/