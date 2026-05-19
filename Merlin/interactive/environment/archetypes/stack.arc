# Stacks can hold items (e.g. props). When they do, the items in the stack all share
# the same spatial bounds — that of the stack.
archetype "stack" [512] /obs /non_occluder /occupies_env_grid
{
    "birth_date"
    "stack_label"
    "items"
    "top"
    "obb"
}
