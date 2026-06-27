# Stacks can hold items (e.g. props). When they do, the items in the stack all share
# the same spatial bounds - that of the stack.
archetype "stack" (cap 512) (per obs) (non-occluder) (occupies-env-grid)
{
    "birth_date"
    "stack_label"
    "items"
    "top"
    "obb"
}
