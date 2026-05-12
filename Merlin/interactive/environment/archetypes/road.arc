# Streets and roads. Used by the historical sim's geography.cfg to anchor
# building addresses (a building's `address` attr points at its road, or
# at itself for estate grounds with no street). Roads persist into the
# interactive sim - NPCs may navigate by road name.
archetype "road" [128] /obs /always_visible /non_occluder
{
    "obb"
    "name" /auto_percept
    "region"
    # Nav v2 Phase 3 spline geometry. Written by Game.cc's LoadScene
    # bridge from the entity's SplineComponent + t_road_component CVs.
    # The /spline_geometry value is consumed by
    # Environment::resolve_road_network to build the
    # t_road_network_index that nav_graph's spline-islands plug into.
    "spline_geometry"
    # Legacy Phase 1 nav-mesh path - kept for the "street plate" test
    # scaffold; new authored roads use /spline_geometry instead.
    "nav_mesh"
}
