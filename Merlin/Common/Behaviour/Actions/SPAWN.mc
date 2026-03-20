
action ?actorEnt SPAWN ?entDescr ?beliefList
    ->
(makeEntity (internalize ?entDescr)): ?ent
(setOccluderAttr ?ent 0)
(perceiveAttr ?ent "obb")
(if (neq ?beliefList @u)
    (beginBelief ?beliefList (perceiveEntity ?ent)))
(setActionOutcome /succ).
