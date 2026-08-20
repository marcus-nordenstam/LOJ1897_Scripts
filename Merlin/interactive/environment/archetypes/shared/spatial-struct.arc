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
#                                content-supplied (space=interior_space, building=building,
#                                town=town) so the engine never names a level.
#   (containment)                LEGACY building sense (space-of-entity, then ascend);
#                                superseded by (rung building)
#   (payload)                    the finest rung: (spatial ?x bounds) yields the exact box
#                                via the live perceiving-pointer (live-only; @unknown when
#                                not perceiving). /env reads env ground truth.
#   (head)                       peek the ordered head (ordered store only)
#   (co)                         same-parent PREDICATE: (spatial ?a co-located ?b)
#                                is true when parent(a) == parent(b) (a shares b's space;
#                                add /building to compare buildings). Kind arg0 tests any
#                                occupant of b's space/building
#   (first)                      single first-known child match: (spatial ?whole room [k K])
#                                yields one perceived room of ?whole (is-a K when given)
#
# STORES: the physical edge types + their behavior. The store id is declaration
# ORDER (space=0, grip=1, stack=2), which the engine addresses by name through
# the registry - no placement enum survives in C++. Flags: (mobile) edges move at
# runtime; (excl) a child has one parent; (ordered) the store maintains head order
# (stack top); (subjective) a mind's value can diverge from env truth. Stores MUST
# precede the views that reference them.
(spatial-struct space    (mobile) (excl) (subjective))
(spatial-struct grip     (mobile) (excl))
(spatial-struct stack    (mobile) (excl) (ordered))
(spatial-struct part     (immutable) (excl))

# The immutable structural topology (the old struct_skeleton), read through the
# same fused (spatial ?ent <view> /env?) op: `parts` = a whole's children (down).
# Default plane = belief-honest (perceived); /env = every edge in the environment
# (all rooms of a building, etc.). A part's enclosing whole (the up-read) is the
# `parent` term, resolved per-archetype by the op's struct fallback.
(spatial-label parts (spatial-struct part) (down))

(spatial-label bounds     (spatial-struct space) (payload))
(spatial-label space      (spatial-struct space) (rung interior_space))
(spatial-label building   (spatial-struct space) (rung building))
(spatial-label town       (spatial-struct space) (rung town))
(spatial-label contents   (spatial-struct space) (down))
(spatial-label co-located (spatial-struct space) (co))
(spatial-label room       (spatial-struct space) (first))
(spatial-label gripped_by (spatial-struct grip))
(spatial-label grip       (spatial-struct grip) (down))
(spatial-label hold       (spatial-struct grip) (down) (descend))
(spatial-label held_by    (spatial-struct grip) (up) (ascend))
(spatial-label in_stack   (spatial-struct stack))
(spatial-label top        (spatial-struct stack) (head))
