
action ?actorEnt STOW ?thingEnt
    ->
(callForeignAction)
(if (actionDone) [
    # Release ?thingEnt from the hand that grips it
    (attr ?thingEnt "controlledBy"): ?prevGripperEnt
    (removeAttrItem ?prevGripperEnt "control" ?thingEnt)
    (perceiveAttr ?prevGripperEnt "control")
    # Set that ?thingEnt is now controlled by @self (stowed on body)
    (setAttr ?thingEnt "controlledBy" @self)
    (addAttrItem @self "control" ?thingEnt)
    # Collapse local OBB to zero (item is hidden on body)
    (setAttr ?thingEnt "obb" /localPos 0 0 0)
]).
