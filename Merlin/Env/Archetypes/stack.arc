# Stacks can hold items (e.g. props).  When they do, the items in the stack all share
# the same spatial bounds - that of the stack.
archetype "stack" [512] /obs
{
    "isa"           kind                                /kind               /passivePercept
    "date"          date                                /date
    "stackLabel"    str                                                     /passivePercept

    # ENTITY attrs
    "in"            entity [4] "structure" "space"       /spatialContainment /imperceptible
    "items"         entity [16]
    "top"           entity

    # SPATIAL BOUNDS attrs
    "obb"           obb                                 /spatialBounds      /passivePercept
}
