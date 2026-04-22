

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
(bb_write @self go_count 1)
(maintainProposal {@self WALK_TO ?obb}).

rule go-entity-walk-to-retry
{@self go_entity ?dest}: ?go
{?dest obb !@unknown:?obb}
{@self WALK_TO ?obb /fail /causes ~?go}
(wait /cycles 180)
    ->
(bb_read @self go_count): ?go_count
(bb_write @self go_count (add ?go_count 1))
(if (lt ?go_count 10)
    (maintainProposal {@self WALK_TO ?obb})
    (setOutcome ?go /fail)).

rule go-entity-outcome-success
{@self /ever go_entity ?dest /noOut}: ?go
{@self /succ WALK_TO ? /causes ~?go}
    ->
(setOutcome ?go /succ).

rule go-entity-outcome-interrupted
{@self /ever go_entity ?dest /noOut}: ?go
{@self /interrupt WALK_TO ? /causes ~?go}
    ->
(setOutcome ?go /interrupt).


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
