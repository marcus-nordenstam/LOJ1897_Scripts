
action ?actorEnt PUT ?thingEnt
    ->
# Release ?thingEnt from whatever controls it (hand or body)
(attr ?thingEnt "controlledBy"): ?prevGripperEnt
(removeAttrItem ?prevGripperEnt "control" ?thingEnt)
(perceiveAttr ?prevGripperEnt "control")
# Remove from carry list if stowed
(removeAttrItem @self "carry" ?thingEnt)
(endBelief {@self carry ?thingEnt})
# Bake world OBB to local so the item stays at its current world position
(setAttr ?thingEnt "obb" (worldObb ?thingEnt))
# Clear controlledBy so the item is now independent
(setAttr ?thingEnt "controlledBy" @nothing)
# Notify GRYM to unparent the item
(fillForeignAction)
(setActionOutcome /succ).
