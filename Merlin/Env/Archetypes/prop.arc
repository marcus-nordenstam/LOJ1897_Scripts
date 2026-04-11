# Any object that is potentially mobile
archetype "prop" [1024] /obs
{
    "date"
    "color"
    # Some props are broken, some are whole, etc.
    "condition"
    # Maybe some props have an actual name, though rare
    "name" /auto-percept
    "writings"
    "parts" /auto-percept
    "in"
    "controlledBy"
    "controlForce"
    "control"
    "inStack"
    # If prop is in a stack, obb is set to @nothing
    "obb"
}
