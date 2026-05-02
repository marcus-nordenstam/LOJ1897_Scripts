

# NOTE that going to and locating documents must be done differently
# since documents are in stacks; so these rules only apply for non-documents destinations.

# These are general go-to-entity rules

rule go-entity-locate-proposal
{@self go_entity ?dest} 
{?dest obb @unknown}
    ->
(maintain_proposal {@self locate ?dest}).

rule go-entity-walk-to-proposal
{@self go_entity ?dest}: ?go
{?dest obb !@unknown:?obb}
    ->
(bb_private_write ?go attempt 1)
(maintain_proposal {@self WALK_TO ?obb}).

rule go-entity-walk-to-retry
{@self go_entity ?dest}: ?go
{?dest obb !@unknown:?obb}
{@self WALK_TO ?obb /fail /causes ~?go}
(wait /cycles 120)
    ->
(bb_private_read ?go attempt): ?go_count
(bb_private_write ?go attempt (add ?go_count 1))
(if (lt ?go_count 10)
    (maintain_proposal {@self WALK_TO ?obb})
    (set_outcome ?go /fail)).

rule go-entity-outcome-success
{@self /ever go_entity ?dest /no_out}: ?go
{@self /succ WALK_TO ? /causes ~?go}
    ->
(set_outcome ?go /succ).

rule go-entity-outcome-interrupted
{@self /ever go_entity ?dest /no_out}: ?go
{@self /interrupt WALK_TO ? /causes ~?go}
    ->
(set_outcome ?go /interrupt).


# These are general go-to-env-cell rules

rule go-env-cell-walk-to-proposal
{@self go_env_cell ?env_cell}: ?go
    ->
(bb_private_write ?go attempt 1)
(maintain_proposal {@self WALK_TO ?env_cell}).

rule go-env-cell-walk-to-retry
{@self go_env_cell ?env_cell}: ?go
{@self WALK_TO ?env_cell /fail /causes ~?go}
(wait /cycles 120)
    ->
(bb_private_read ?go attempt): ?go_count
(bb_private_write ?go attempt (add ?go_count 1))
(if (lt ?go_count 10)
    (maintain_proposal {@self WALK_TO ?env_cell})
    (set_outcome ?go /fail)).

rule go-env-cell-interrupt
{@self /ever go_env_cell ?env_cell /no_out}: ?go
{@self /interrupt WALK_TO ?env_cell /causes ~?go}
    ->
(set_outcome ?go /interrupt).

rule go-env-cell-success
{@self /ever go_env_cell ?env_cell /no_out}: ?go
{@self /succ WALK_TO ?env_cell /causes ~?go}
    ->
(set_outcome ?go /succ).
