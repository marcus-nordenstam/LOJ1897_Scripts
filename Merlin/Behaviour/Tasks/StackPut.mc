
rule stack-put-keep-near-and-facing-proposal
{@self stack_put ? ?stack}
{?stack isa [k object stack]}
    ->
(maintainProposal {@self keep_near_and_facing ?stack} (abs_util 1000)).


rule stack-put-get-thing-proposal
{@self stack_put ?thing ?stack}
{?stack isa [k object stack]}
{@self hand ?hand}
{?hand control !?thing}
    ->
(maintainProposal {@self get ?thing}).


rule stack-put-action-proposal
{@self stack_put ?thing ?stack}
{?stack isa [k object stack]}
{?hand control ?thing}
{@self hand ?hand}
{@self within_reach_of ?stack}
    ->
(maintainProposal {@self STACK_PUT ?thing ?stack}).


# Base the activity's outcome on the corresponding action's outcome
rule stack-put-outcome
{@self /ever stack_put ?thing ?stack /noOut}: ?put
{@self /past STACK_PUT ?thing ?stack /causes ~?put}: ?PUT
    ->
(setOutcome ?put (outcome ?PUT)).
