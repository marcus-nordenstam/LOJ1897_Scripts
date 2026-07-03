# Stacks can hold items (e.g. props). When they do, the items in the stack all share
# the same spatial bounds - that of the stack. The `items` inverse (and `top`) are
# maintained by the env in_stack seam (attr.cc update_stack_in_environment) - the
# single writer, mirroring how location<->contents is seam-maintained.
archetype "stack" (cap 512) (per obs) (non-occluder) (occupies-env-grid)
{
    "birth_date"
    "stack_label"
    "items"
    "top"
    "obb"
    # A stack sits IN a space (a mail pile in the hallway, letter piles inside
    # a hiding-spot cache) - seam-derived from the OBB like any located prop.
    "location"
}
