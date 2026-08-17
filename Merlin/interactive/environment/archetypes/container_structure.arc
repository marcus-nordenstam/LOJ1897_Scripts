# Immobile structures with their own internal cell-space (buildings, ships, wagons, train_cars).
# Distinguished from `structure` (pier, bridge) by having a container_id (auto-injected in code, not listed here).
archetype "container_structure" (cap 2048) (per obs) (always-visible) (children-occupy-env-grid)
{
    # Kind-variation identity (see attr/common.arc).
    (attr "variant")
    (attr "birth_date")
    # Name is auto-perceived so NPCs know what building they're in.  The
    # ext-mech override (common.arc names default to imperceptible for humans)
    # lets the visual sensor tag perceived building-name beliefs as OBS so
    # they live in the OBS pool.  Stopgap until address signs become
    # observable entities.
    (attr "name" (auto-percept) (ext-per obs))
    (spatial bounds)
    # Building physical / structural properties (historical sim writes
    # these; crime templates and behaviour rules may match on them).
    (attr "isolated")
    (attr "has_crypt")
    (attr "locked_wing")
    # Premises open/closed STATUS (no-telepathy teardown): [k closed] = shuttered. Set on
    # the building by the owner's closure act (shutter-building ?wp). Since NPCs ALWAYS
    # front-park a building on arrival (Stage-5 two-arm), a worker RE-OBSERVES it every
    # commute via exterior perception and internalizes {building struct_status [k closed]}
    # fresh; reconcile_closed drops his own stale employer/job beliefs off that perceived
    # belief. hsim-perceptible, kind-valued open|closed (common.arc).
    (attr "struct_status")
    (attr "era_min")
    (attr "era_max")
    # Address - road the building is on, OR self-reference for estates.
    # See common.arc for the _ convention on address_number.
    (attr "address")
    (attr "address_number")
    (attr "region")
    # Nav v2: cache key into nav_graph's mesh-data table.
    (attr "nav_mesh")
    # Nav v2: container_structures (buildings/ships/wagons) physically occupy
    # their footprint - rasterise as terrain blockers so terrain pathfinding
    # routes around them. Connector throat clearing (§7.3) re-opens the cells
    # under each baked passage so doors stay walkable.
    (attr "blocks_nav_terrain")
}
