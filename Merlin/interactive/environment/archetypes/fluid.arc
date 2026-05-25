# Fluids (beer, wine, water, etc.) - observable, can be controlled by a
# container. Tampering / poisoning is now recorded via the `add_substance`
# verb-state in States.mon (PR-evi-C 2026-05-25, migrated from the retired
# `tainted_with` attr); both perpetrator's act-record and any witnessing
# beliefs use the same belief shape rather than splitting between an env
# attr and a belief.
archetype "fluid" (cap 256) (mech obs) (occupies-env-grid) (non-occluder)
{
    "controlled_by"
    "fluid_amount"
    "obb"
}
