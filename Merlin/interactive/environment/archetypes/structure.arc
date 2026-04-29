# Immobile objects such as buildings
archetype "structure" [2048] /obs /always_visible /children_occupy_env_grid
{
    "date"
    # Name is perceptible so NPCs know what building they're in
    # Name is auto-perceived so NPCs know what building they're in
    "name" /auto_percept
    "parts" /auto_percept
    "obb"
    # Building physical / structural properties (historical sim writes
    # these; crime templates and behaviour rules may match on them).
    "isolated"
    "has_crypt"
    "locked_wing"
    "era_min"
    "era_max"
    # Address - road the building is on, OR self-reference for estates.
    # See common.arc for the @nothing convention on address_number.
    "address"
    "address_number"
    "region"
}
