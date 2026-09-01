; ----------------------------------------------------------------------------
; read-listings ?register - the KNOWLEDGE CHANNEL of the property market: @self walks
; to the house-agency's for-sale REGISTER (a for-sale-listings table-doc) and SCANS the
; written table, minting a {?b availability [k for-sale]} belief for every building it
; lists. Only once he KNOWS what is for sale (belief) does choose_home / the founding lane
; reason over it. Replaces the old stack-browse of per-listing message docs.
; ----------------------------------------------------------------------------

(npc-task {@self read-listings ?register}:?rl-rel
  (tar @excl for-sale-listings)
  (and
    ; WALK: not at the register -> go to its room.
    (try
      (role ?reg [k for-sale-listings] (= ?reg ?register)
            (not (spatial ?reg co-located @self)))
      (when (spatial ?reg space): ?room)
      (effects (maintain-proposal {@self WALK ?room})))
    ; READ: at the register -> scan the table, minting an availability belief per row.
    (try
      (when (spatial ?register co-located @self))
      (effects
        (for-each-row (attr ?register writing) (building ?b)
          (begin-belief {?b availability [k for-sale]}))
        (set-outcome ?rl-rel /succ)))))
