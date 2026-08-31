# This can be a part of a structure OR a prop
archetype "part" (cap 2048) (per obs)
{
    # Kind-variation identity (see shared/attrs.arc).
    (attr "variant")
    (attr "birth-date")
    # Part name observable (e.g. a part of a structure or labeled prop-part).
    # ext-mech override - common.arc leaves name imperceptible for the human model.
    (attr "name" (auto-percept) (ext-per obs))
    (spatial bounds)
}
