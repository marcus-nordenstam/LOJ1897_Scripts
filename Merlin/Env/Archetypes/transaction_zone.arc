archetype "transaction_zone" [256] /obs /alwaysVisible /nonOccluder
{
    "isa"              kind                                /kind               /passivePercept
    "parent"           entity                              /parent
    "obb"              obb                                 /spatialBounds      /passivePercept
    "provider_station" entity "transaction_station"        /passivePercept
    "receiver_station" entity "transaction_station"        /passivePercept
}
