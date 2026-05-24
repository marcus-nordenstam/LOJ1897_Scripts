# Any object that is potentially mobile
archetype "prop" (cap 1024) (mech obs) (occupies-env-grid) (non-occluder)
{
    "birth_date"
    "color"
    # Some props are broken, some are whole, etc.
    "condition"
    # Maybe some props have an actual name, though rare.  ext-mech override -
    # common.arc leaves name imperceptible for the human model; props with a
    # visible label / engraving / sign need observable names.
    "name" (auto-percept) (ext-mech obs)
    "writing"
    "parts" (auto-percept)
    "controlled_by"
    "control_force"
    "control"
    "in_stack"
    # If prop is in a stack, obb is set to _
    "obb"
}
