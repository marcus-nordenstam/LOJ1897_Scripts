# A pile holds N identical FUNGIBLE items as ONE self-contained entity: it
# stores the item KIND (content_kind) and a COUNT, never per-item entities.
# Unlike a stack there are NO member entities to de-grid - the pile's own box
# IS the heap. It sits IN a space (seam-derived from its OBB) like any located
# prop, and its bounds are the pile SHAPE.
archetype "pile" (cap 4096) (per obs) (non-occluder) (occupies-env-grid)
{
    # Placement participation (plan section 18): a pile takes part in the
    # space relation only - it has no items edge (nothing is filed into it).
    (spatial space)
    (spatial bounds)
    # Kind-variation identity (see shared/attrs.arc).
    (attr "variant")
    (attr "birth_date")
    # The fungible payload: what kind sits in the pile, and how many.
    (attr "content_kind")
    (attr "count")
}
