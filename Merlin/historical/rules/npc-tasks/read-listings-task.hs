; ----------------------------------------------------------------------------
; read_listings ?register - the KNOWLEDGE CHANNEL of the property market: @self walks
; to the house-agency's for-sale REGISTER (a for_sale_listings table-doc) and SCANS the
; written table, minting a {?b availability [k for_sale]} belief for every building it
; lists. Only once he KNOWS what is for sale (belief) does choose_home / the founding lane
; reason over it. Replaces the old stack-browse of per-listing message docs.
; ----------------------------------------------------------------------------

(npc-task {@self read_listings ?register}:?rl-rel
  (tar @excl for_sale_listings)
  (and
    ; WALK: not at the register -> go to its room.
    (try
      (role ?reg [k for_sale_listings] (= ?reg ?register)
            (not (spatial ?reg co-located @self)))
      (when (spatial ?reg space): ?room)
      (effects (debug-print "RL_WALK") (maintain-proposal {@self WALK ?room})))
    ; READ: at the register -> scan the table, minting an availability belief per row.
    (try
      (when (spatial ?register co-located @self))
      (effects
        (debug-print "RL_READ")
        (for-each-row (attr ?register writing) (building ?b)
          (begin-belief {?b availability [k for_sale]}))
        (set-outcome ?rl-rel /succ)))))
