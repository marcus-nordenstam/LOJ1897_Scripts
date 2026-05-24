# This can be a part of a structure OR a prop
archetype "part" (cap 2048) (mech obs)
{
    "birth_date"
    # Part name observable (e.g. a part of a structure or labeled prop-part).
    # ext-mech override - common.arc leaves name imperceptible for the human model.
    "name" (auto-percept) (ext-mech obs)
    "struct_parent"
    "parts" (auto-percept)
    "obb"
}
