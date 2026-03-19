action ?actorEnt POUR ?fluidEnt ?containerEnt
    ->
(setAttr ?fluidEnt "obb" /localPos 0 0 0)
(setAttr ?fluidEnt "controlledBy" ?containerEnt)
(setAttr ?fluidEnt "fluid_amount" 1)
(callForeignAction)
(if (actionDone)
    (setActionOutcome /succ)).
