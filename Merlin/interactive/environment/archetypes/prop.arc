# Any object that is potentially mobile
# cap: the full St-Revier geography seeds household props per building, and
# a century of runs accumulates PERMANENT paper evidence by design (the
# police-station crime-report archive, receipts, sales_records, letters) -
# the 4096 cap died mid-run at 1734.
archetype "prop" (cap 12288) (mech obs) (occupies-env-grid) (non-occluder)
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
    # The building a loose prop currently sits in. Written by the hsim
    # evidence trails (receipt / sales_record, letters, hiding caches) and
    # read back by their location scans; without it those `at` writes were
    # silent no-ops and the scans could never find anything.
    "at"
    "in_stack"
    # If prop is in a stack, obb is set to _
    "obb"
    # PR-evi-A 2026-05-25 - per-object evidence attrs. A blood-stained
    # weapon, gunpowder-residue on a coat, scratch-marks on a lock-pick.
    # Wounds are body-only (no `wounds` attr on props).
    "stains"
    "marks"
}
