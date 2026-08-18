# Spatial-struct view declarations (spatial_struct_unification_plan.md sections 3-4).
#
# A VIEW is a named lens over a physical edge store; the (spatial ?ent <view>) read
# op and the (spatial-write ...) op resolve their relation argument to one of these
# records, never a hardcoded C++ name compare. Each view names its store and its
# read decorations:
#   (store location|grip|stack)  which physical edge store this view reads
#   (up)                         single-target read (default; explicit for clarity)
#   (down)                       list read (the store's inverse / occupants side)
#   (ascend)                     one struct-parent hop after an up-view
#   (descend)                    struct-parts hop before a down-view
#   (containment)                the building sense (space-of-entity, then ascend)
#   (head)                       peek the ordered head (ordered store only)
#
# STAGE-2 NOTE: the three store names still bind to the placement enum in
# spatial_views.cc; stage 3 retires the enum for a runtime store id, at which point
# the (spatial-struct "...") store decls with mobility flags land here too.

(view location   (store location))
(view building   (store location) (containment))
(view contents   (store location) (down))
(view gripped_by (store grip))
(view grip       (store grip) (down))
(view hold       (store grip) (down) (descend))
(view held_by    (store grip) (up) (ascend))
(view in_stack   (store stack))
(view top        (store stack) (head))
