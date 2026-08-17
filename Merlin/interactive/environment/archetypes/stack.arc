# Stacks can hold items (e.g. props). When they do, the items in the stack all share
# the same spatial bounds - that of the stack. Membership + order live in the
# placement index (whereabouts_chains stack edges; head = exposed item), written
# only by the filing seam (t_environment::file_in_stack / unfile_from_stack).
# Cap sized for the mail model over a long run: two piles per premises (~400)
# plus two per hiding-spot cache - caches accrue one per new affair pairing
# for decades - plus the registry stacks (a 20yr run hit 512).
archetype "stack" (cap 2048) (per obs) (non-occluder) (occupies-env-grid)
{
    # Placement participation (plan section 18): which spatial relations this
    # archetype takes part in - the write seams validate both ends.
    (spatial location)
    (spatial items)
    # Kind-variation identity (see attr/common.arc).
    (attr "variant")
    (attr "birth_date")
    (attr "stack_label")
    (attr "obb")
    # A stack sits IN a space (a mail pile in the hallway, letter piles inside
    # a hiding-spot cache) - seam-derived from the OBB like any located prop.
    # A pile is created as a CHILD of its mail space so find_mail_stack's
    # child walk resolves it regardless of where the placement seam files its
    # contents entry. Without this attr, set_parent silently no-ops and every
    # delivery minted a duplicate pile (the 2048-cap stack-pool exhaustion).
}
