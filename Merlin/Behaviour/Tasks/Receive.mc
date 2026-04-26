
# Receive is similar to get, except it involves a giver, 
# whom we must be close to, and whose actions we must observe
# (get only tracks the item, since there is no giver)

rule receive-maintain-within-reach-of-proposal
{@self receive ?thing ?giver}
    ->
(maintain_proposal {@self keep_near_and_facing ?giver} (abs_util 1000)).


rule receive-take-proposal
{@self receive ?thing ?giver}
{?thing obb !@unknown}
{@self within_reach_of ?giver}
{@self facing ?giver}
(real ?thing)
    ->
(maintain_proposal {@self take ?thing}).


# Base the activity's outcome on the corresponding take task's outcome
rule receive-outcome
{@self /ever receive ?thing /noOut}: ?receive
{@self /past take ?thing /causes ~?receive}: ?take
    ->
(set_outcome ?receive (outcome ?take)).

