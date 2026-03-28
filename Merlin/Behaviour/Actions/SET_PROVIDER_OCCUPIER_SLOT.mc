
action ?actorEnt SET_PROVIDER_OCCUPIER_SLOT ?occupier ?station
    ->
(setAttr ?station "staging_spot_occupier" ?occupier)
(setActionOutcome /succ).
