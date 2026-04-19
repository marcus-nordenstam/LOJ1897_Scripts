
rule stack-get-keep-near-and-facing-proposal
{@self stack_get ? ?stack}
{?stack isa [k object stack]}
    ->
(maintainProposal {@self keep_near_and_facing ?stack} /absUtil 1000).


rule stack-get-stack-take-proposal
{@self stack_get ?thing ?stack}
{?stack isa [k object stack]}
{@self hand ?hand}
{?hand control @nothing}
{@self within_reach_of ?stack}
    ->
(maintainProposal {@self STACK_TAKE ?thing ?hand}).


# Base the activity's outcome on the corresponding action's outcome
rule stack-get-outcome
{@self /ever stack_get ?thing ?stack /noOut}: ?get
{@self /past STACK_TAKE ?thing ? /causes ~?get}: ?TAKE
    ->
(setOutcome ?get /from ?TAKE).
