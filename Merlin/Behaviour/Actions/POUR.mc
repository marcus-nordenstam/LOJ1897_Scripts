action ?actorEnt POUR ?fluidEnt ?containerEnt
    ->
(callForeignAction)
(if (actionDone)
    [(setAttr ?fluidEnt "obb" /localPos 0 0 0)
     (setAttr ?fluidEnt "controlledBy" ?containerEnt)
     (addAttrItem ?containerEnt "control" ?fluidEnt)
     (perceiveAttr ?containerEnt "control")
     (setAttr ?fluidEnt "fluid_amount" 1)]).
