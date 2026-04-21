# Immobile objects such as buildings
archetype "structure" [512] /obs /always_visible /children_occupy_env_grid
{
    "date"
    # Name is perceptible so NPCs know what building they're in
    # Name is auto-perceived so NPCs know what building they're in
    "name" /auto_percept
    "parts" /auto_percept
    "obb"
}
