# Oftentimes, NPCs will need to transact involving some goods or items
# This structure formalizes the necessary spatial relationships by providing 
# specific locations indicating where each party may stand, and where items 
# may be dropped/picked up.

archetype "transaction_station" [256] /obs /alwaysVisible /nonOccluder /sectorCoverage
{
    "isa"                   kind                        /kind               /passivePercept
    "obb"                   obb                         /spatialBounds      /passivePercept

    "actor_spot_holder"     entity                                          /passivePercept

    "staging_spot"          entity "location"                               /passivePercept
    "staging_spot_occupier" entity                                          /passivePercept

    "counterpart_station"   entity "transaction_station"                    /passivePercept
}
