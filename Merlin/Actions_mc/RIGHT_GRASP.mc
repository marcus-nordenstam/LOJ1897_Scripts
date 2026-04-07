
action ?actorEnt RIGHT_GRASP ?thingEnt
    ->
# If the thing is being gripped hard, this action fails
(attr ?thingEnt "controlForce"): ?curGripperForce
(if (eq ?curGripperForce 1)
    (setActionOutcome /fail))
# Call handler for visual socket attachment
(callForeignAction)
(if (actionDone) [ 
    # Get the right hand entity
    (attr ?actorEnt "rightHand"): ?handEnt
    # Release ?thingEnt from whatever currently controls it
    (attr ?thingEnt "controlledBy"): ?prevGripperEnt
    (removeAttrItem ?prevGripperEnt "control" ?thingEnt)
    (perceiveAttr ?prevGripperEnt "control")
    # Set that ?thingEnt is now gripped by ?handEnt
    (setAttr ?thingEnt "obb" /localPos 0 0 0)
    (addAttrItem ?handEnt "control" ?thingEnt)
    (setAttr ?thingEnt "controlledBy" ?handEnt)
    (setAttr ?thingEnt "controlForce" 1)
    # Notice that actor is now holding ?thingEnt
    (perceiveEntity ?thingEnt)
    (perceiveAttr ?handEnt "control")
    ]).
