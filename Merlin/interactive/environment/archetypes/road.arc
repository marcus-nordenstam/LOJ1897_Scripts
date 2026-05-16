# Streets and roads. Used by the historical sim's geography.cfg to anchor
# building addresses (a building's `address` attr points at its road, or
# at itself for estate grounds with no street). Roads persist into the
# interactive sim - NPCs may navigate by road name.
archetype "road" [128] /obs /always_visible /non_occluder
{
    # Roads are spline-shaped, not OBB-shaped: their spatial geometry is the
    # CV polyline in /spline_geometry, not a single bounding box. The
    # archetype-parse-time mutex (PopulationStorage::_activateAttrs) forbids
    # declaring both /spatial_bounds and /spline_geometry on the same
    # archetype, so "obb" is intentionally absent here.
    "name" /auto_percept
    "region"
    # Nav v2 Phase 3 spline geometry. Written inline by Game.cc's LoadScene
    # entity-creation dispatch (k_spline branch) from the GRYM
    # SplineComponent + t_road_component CVs. Consumed by
    # Environment::resolve_road_network to build the t_road_network_index
    # that nav_graph's spline-islands plug into.
    "spline_geometry"
    # Legacy Phase 1 nav-mesh path - kept for the "street plate" test
    # scaffold; new authored roads use /spline_geometry instead.
    "nav_mesh"
}
