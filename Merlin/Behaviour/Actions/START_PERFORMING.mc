
action ?actorEnt START_PERFORMING ?activityKind ?placeEnt
    ->
# Only start if not already performing
(attr ?actorEnt "perform"): ?curActivity
(if (eq ?curActivity @nothing)
    [(makeEntity ?activityKind): ?activityEnt
     (setAttr ?activityEnt "at" ?placeEnt)
     (setAttr ?actorEnt "perform" ?activityEnt)])

# Be aware of what we're now performing
(perceiveAttr ?actorEnt "perform")

# The action always succeeds
(setActionOutcome /succ).
