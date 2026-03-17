
action ?actorEnt STOW ?thingEnt
    ->
# Release ?thingEnt from the hand that grips it
(attr ?thingEnt "controlledBy"): ?prevGripperEnt
(removeAttrItem ?prevGripperEnt "control" ?thingEnt)
(perceiveAttr ?prevGripperEnt "control")
# Set that ?thingEnt is now controlled by @self (stowed on body)
(setAttr ?thingEnt "controlledBy" @self)
# Collapse local OBB to zero (item is hidden on body)
(setAttr ?thingEnt "obb" /localPos 0 0 0)
# Add to carry list
(addAttrItem @self "carry" ?thingEnt)
(beginBelief {@self carry ?thingEnt})
(fillForeignAction)
(setActionOutcome /succ).
