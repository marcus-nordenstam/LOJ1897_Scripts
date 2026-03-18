
action ?actorEnt TURN_TO ?obb
    ->
(callForeignAction)
(if (isFacing ?obb 0.98) (setActionOutcome /succ)).
