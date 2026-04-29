# Streets and roads. Used by the historical sim's geography.cfg to anchor
# building addresses (a building's `address` attr points at its road, or
# at itself for estate grounds with no street). Roads persist into the
# interactive sim - NPCs may navigate by road name.
archetype "road" [128] /obs /always_visible /non_occluder
{
    "obb"
    "name" /auto_percept
    "region"
}
