
# To read it, you must have it
rule read-get-proposal
{@self read ?doc}
{@self hand ?hand}
{?hand control !?doc}
    ->
(maintain_proposal {@self get ?doc}).

rule read-action-proposal
{@self read ?doc}
{@self hand ?hand}
{?hand control ?doc}
    ->
(maintain_proposal {@self READ ?doc}).


# Base the activity's outcome on the corresponding action's outcome
rule read-outcome
{@self /ever read ?doc /no_out}: ?read
{@self /past READ ?doc /causes ~?read}: ?READ
    ->
(set_outcome ?read (outcome ?READ)).