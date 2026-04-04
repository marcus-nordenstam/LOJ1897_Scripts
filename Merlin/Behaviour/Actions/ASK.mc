
action ?actorEnt ASK ?question ?personEnt
    ->
# Create a sound entity on first firing only
(attr ?actorEnt "obb"): ?actorObb
(if (isFirstFiring) [
    (makeEntity [[k sound speech] ?actorObb (floats 6 6 6) (floats 0 0 0 1)]): ?soundEnt
    (setAttr ?soundEnt "createAction" (extAction))
    (setAttr ?soundEnt "speaker" ?actorEnt)
])
# Call handler — outcome signalled when speech completes
(callForeignAction).
