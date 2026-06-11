# Fluids (beer, wine, water, concentrated poisons, etc.) - observable, can
# be controlled by a container. The perpetrator's ACT of tampering is the
# `add_substance` belief verb-state (States.mon, PR-evi-C 2026-05-25,
# migrated from the retired `tainted_with` attr); the PHYSICAL fact that a
# drink IS laced - the forensic ground truth an analysis reveals,
# independent of any mind - is the `taint` attr below (common.arc). The two
# are complementary: the belief is who-did-it (mind-held), the attr is
# what-the-drink-contains (env ground truth).
archetype "fluid" (cap 256) (mech obs) (occupies-env-grid) (non-occluder)
{
    "controlled_by"
    "fluid_amount"
    # Poison lacing this drink (imperceptible ground truth - see common.arc).
    "taint"
    "obb"
}
