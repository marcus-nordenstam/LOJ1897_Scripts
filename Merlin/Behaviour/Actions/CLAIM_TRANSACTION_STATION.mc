
action ?actorEnt CLAIM_TRANSACTION_STATION ?zoneEnt ?stationAttrName
    ->
# Read the station entity from the zone's given attr (e.g. "receiver_station")
(attr ?zoneEnt ?stationAttrName): ?stationEnt
# Check if it's already claimed — if so, fail
(attr ?stationEnt "actor_spot_holder"): ?currentHolder
(if (neq ?currentHolder @nothing)
    (setActionOutcome /fail))
# Claim it: set the holder to the acting NPC
(setAttr ?stationEnt "actor_spot_holder" ?actorEnt)
(perceiveAttr ?stationEnt "actor_spot_holder")
(setActionOutcome /succ).
