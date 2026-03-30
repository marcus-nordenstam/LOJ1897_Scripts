
action ?actorEnt STOP_PERFORMING ?activityEnt
    ->
# Only stop if currently performing this activity
(attr ?actorEnt "perform"): ?curActivity
(if (eq ?curActivity ?activityEnt)
    (destroyEntity ?activityEnt))

# Be aware that we're no longer performing
(perceiveAttr ?actorEnt "perform")

# The action always succeeds
(setActionOutcome /succ).
