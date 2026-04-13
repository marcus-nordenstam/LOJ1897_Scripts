

# NOTE that going to and locating documents must be done differently
# since documents are in stacks; so these rules only apply for non-documents destinations.

# These are general go-to-entity rules

rule go-entity-locate-proposal
{@self go_entity ?dest} 
{?dest obb @unknown}
    ->
(maintainProposal {@self locate ?dest}).


rule go-entity-walk-to-proposal
{@self go_entity ?dest}
{?dest obb !@unknown:?obb}
    ->
(maintainProposal {@self WALK_TO ?obb}).

# Base the activity's outcome on the corresponding action's outcome
rule go-entity-outcome
#{@self /ever go ![k document]:?dest /noOut}: ?go
{@self /ever go_entity ?dest /noOut}: ?go
{?dest obb ?obb}
{@self /past WALK_TO ?obb /causes ~?go}: ?WALK
    ->
(setOutcome ?go /from ?WALK).


# These are general go-to-env-cell rules

rule go-env-cell-walk-to-proposal
{@self go_env_cell ?env_cell}
    ->
(maintainProposal {@self WALK_TO ?env_cell}).


rule go-env-cell-outcome
{@self /ever go_env_cell ?env_cell /noOut}: ?go
{@self /past WALK_TO ?env_cell /causes ~?go}: ?WALK
    ->
(setOutcome ?go /from ?WALK).
