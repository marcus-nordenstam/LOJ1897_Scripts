
action ?actorEnt MIRROR ?target
    ->
(callForeignAction)
(if (isMirroring ?target 0.98) (setActionOutcome /succ)).
