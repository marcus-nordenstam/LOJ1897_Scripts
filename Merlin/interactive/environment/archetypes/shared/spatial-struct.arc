# Spatial-struct + spatial-label declarations (spatial_struct_unification_plan.md sections 3-4).
#
# A SPATIAL-STRUCT is a physical edge store (the storage). A SPATIAL-LABEL is a named
# lens / belief-label over one struct; the (spatial ?ent <label>) read op and the
# (spatial-write ...) op resolve their relation argument to a label record, never a
# hardcoded C++ name compare. Each label names the struct it reads and its decorations:
#   (spatial-struct space|grip|stack)     which physical edge store this label reads
#   (up)                         single-target read (default; explicit for clarity)
#   (down)                       list read (the store's inverse / occupants side)
#   (ascend)                     one struct-parent hop after an up-view
#   (descend)                    struct-parts hop before a down-view
#   (rung <kind>)                a LADDER rung: the subject's known container at (or
#                                above) the granularity of <kind> - ascend the known
#                                containment chain to the first node is-a <kind>. @unknown
#                                when <kind> is finer than what the mind knows. Kept
#                                content-supplied (building=building, town=town) so the
#                                engine never names a level. NOT used by `space`: a space
#                                is whatever directly contains the entity (see below).
#   (payload)                    the finest rung: (spatial ?x bounds) yields the exact box
#                                via the live perceiving-pointer (live-only; @unknown when
#                                not perceiving). /env reads env ground truth.
#   (head)                       peek the ordered head (ordered store only)
#   (co)                         co-presence PREDICATE: (spatial ?a co-located ?b) is true
#                                when a shares b's container. BARE = same immediate place;
#                                add (rung <kind>) to compare at that container level (see
#                                co-located-building). Kind arg0 tests any occupant of that
#                                scope
#   (first)                      single first-known child match: (spatial ?whole room [k K])
#                                yields one perceived child of ?whole is-a the label's (rung
#                                <kind>) range, further narrowed by K when given
#
# A relation's RANGE is fixed by the relation, and a query never returns a kind
# outside it - that is what keeps a call-site's expectation unambiguous. `space` is
# the entity's directly-containing space: a room indoors, the smallest enclosing
# exterior-space outdoors, @unknown when the mind does not know. It is a single up-hop
# (the whereabouts parent), NOT a ladder ascent - it always lands on a space. `building`
# and `town` are their OWN relations (a building is-a object, a town is-a region -
# neither is-a space), so they read the containment chain separately; they are never
# `space` at a coarser granularity.
#
# QUALIFIER (spec, no consumers yet): /ascend [k K] and /descend [k K] walk a relation
# WITHIN its own range - K MUST be is-a that range or the query is a load error. So
# (spatial ?x space /ascend [k area]) is legal (area is-a space) and climbs nested
# exterior spaces neighborhood -> area -> ...; (spatial ?x space /ascend [k building])
# is rejected (building is not a space). Use `building` / `town` for those levels.
#
# STORES: the physical edge types + their behavior. The store id is declaration
# ORDER (space=0, grip=1, stack=2), which the engine addresses by name through
# the registry - no placement enum survives in C++. Flags: (mobile) edges move at
# runtime; (excl) a child has one parent; (ordered) the store maintains head order
# (stack top); (subjective) a mind's value can diverge from env truth. Stores MUST
# precede the views that reference them.
(spatial-struct space    (mobile) (excl) (subjective))
(spatial-struct grip     (mobile) (excl) (recurse-on-obs))
(spatial-struct stack    (mobile) (excl) (ordered))
(spatial-struct part     (immutable) (excl))

# The immutable structural topology (the old struct_skeleton), read through the
# same fused (spatial ?ent <view> /env?) op: `parts` = a whole's children (down).
# Default plane = belief-honest (perceived); /env = every edge in the environment
# (all rooms of a building, etc.). A part's enclosing whole (the up-read) is the
# `parent` term, resolved per-archetype by the op's struct fallback.
(spatial-label parts (spatial-struct part) (down))

(spatial-label bounds     (spatial-struct space) (payload))
(spatial-label space      (spatial-struct space) (theme frequent))
(spatial-label building   (spatial-struct space) (rung building))
(spatial-label town       (spatial-struct space) (rung town))
(spatial-label contents   (spatial-struct space) (down))
(spatial-label co-located (spatial-struct space) (co))
(spatial-label co-located-building (spatial-struct space) (co) (rung building))
(spatial-label room       (spatial-struct space) (first) (rung interior-space))
(spatial-label gripped-by (spatial-struct grip))
(spatial-label grip       (spatial-struct grip) (down))
(spatial-label hold       (spatial-struct grip) (down) (descend))
(spatial-label held-by    (spatial-struct grip) (up) (ascend))
(spatial-label in-stack   (spatial-struct stack))
(spatial-label top        (spatial-struct stack) (head))
