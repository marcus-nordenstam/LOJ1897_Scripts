
action ?actorEnt RELEASE_TRANSACTION_STATION ?stationEnt
    ->
(setAttr ?stationEnt "actor_spot_holder" @nothing)
(setAttr ?stationEnt "staging_spot_occupier" @nothing)
(setActionOutcome /succ).
