# Spaces
archetype "space" [2096] /obs /always_visible /non_occluder /sector_coverage
{
    "birth_date"
    # Name is auto-perceived so NPCs know what space they're in
    "name" /auto_percept
    "struct_parent"
    "parts" /auto_percept
    "obb"
    # Nav v2: spaces can host openings whose /is_nav_passage gates a
    # macro-graph edge (e.g. an archway between rooms).
    "is_nav_passage"
}
