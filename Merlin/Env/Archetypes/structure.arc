# Immobile objects such as buildings
archetype "structure" [512] /obs /always_visible
{
    "date"
    # Name is perceptible so NPCs know what building they're in
    # Name is auto-perceived so NPCs know what building they're in
    "name" /auto_percept
    "in"
    "contains"
    "parts" /auto_percept
    "obb"
}
