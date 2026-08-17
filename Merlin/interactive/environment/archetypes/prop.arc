# Any object that is potentially mobile
# cap: the full St-Revier geography now furnishes every room of every home
# (beds, tables, chairs, dressers, clocks, ornaments, housewares - tens of
# props per dwelling, class-stratified) ON TOP of the weapon seeding, and a
# century of runs accumulates PERMANENT paper evidence by design (the
# police-station crime-report archive, receipts, sales_records, letters) -
# the 4096 cap died mid-run at 1734; 12288 was tight once homes were
# furnished, so the reservation is sized for the furnished world.
archetype "prop" (cap 32768) (per obs) (occupies-env-grid) (non-occluder)
{
    # Placement participation (plan section 18): which spatial relations this
    # archetype takes part in - the write seams validate both ends.
    (spatial controlled_by)
    (spatial control)
    (spatial location)
    (spatial in_stack)
    # Kind-variation identity (see attr/common.arc).
    (attr "variant")
    (attr "birth_date")
    (attr "color")
    # Some props are broken, some are whole, etc.
    (attr "condition")
    # Maybe some props have an actual name, though rare.  ext-mech override -
    # common.arc leaves name imperceptible for the human model; props with a
    # visible label / engraving / sign need observable names.
    (attr "name" (auto-percept) (ext-per obs))
    (attr "writing")
    (attr "control_force")
    # The building a loose prop currently sits in. Written by the hsim
    # evidence trails (receipt / sales_record, letters, hiding caches) and
    # read back by their location scans; without it those `location` writes
    # were silent no-ops and the scans could never find anything.
    (attr "location")
    # The NPC who MADE this prop owns it (a secret cache belongs to its maker).
    # Imperceptible - a hidden cache's ownership is not on show; it gates who may
    # observe the cache's contents (only the owner).
    (attr "owner")
    # The person a letter is addressed to. hsim-perceptible: a mind that observes
    # the letter learns {letter addressee <person>} on sight (the envelope), but
    # NOT the message - reading it is a separate act.
    (attr "addressee")
    (attr "addressee_duty")
    # The written destination street address on a letter (the envelope): the road
    # it fronts plus the house number. The sender copies these from the addressee's
    # building; the magic mail service reverse-maps (road, number) -> building to
    # route the letter to that building's incoming mail_stack.
    (attr "address")
    (attr "address_number")
    # If prop is in a stack, obb is set to _
    (attr "obb")
    # PR-evi-A 2026-05-25 - per-object evidence attrs. A blood-stained
    # weapon, gunpowder-residue on a coat, scratch-marks on a lock-pick.
    # Wounds are body-only (no `wounds` attr on props).
    (attr "stains")
    (attr "marks")
}
