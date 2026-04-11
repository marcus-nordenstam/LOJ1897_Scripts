# Transaction stations formalize spatial relationships for goods/item exchange,
# providing specific locations for each party to stand and for items to be dropped/picked up.
archetype "transaction_station" [256] /obs /alwaysVisible /nonOccluder
{
    "obb"
    "struct_parent"
    "actor_spot_holder"     entity      /obs /auto-percept /state-flags-tar @excl
    "staging_spot_occupier" entity      /obs /auto-percept /state-flags-tar @excl
}
