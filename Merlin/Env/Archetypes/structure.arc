# Immobile objects such as buildings
archetype "structure" [512] /obs /alwaysVisible
{
    "date"
    # Name is perceptible so NPCs know what building they're in
    # Name is auto-perceived so NPCs know what building they're in
    "name" /auto-percept
    "in"
    "contains"
    "parts" /auto-percept
    "obb"
}
