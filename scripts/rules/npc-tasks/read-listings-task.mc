; DORMANT - this lane never ran; revived on the form deeds / articles with its own gauntlet.
;; ----------------------------------------------------------------------------
;; read-listings ?register - the KNOWLEDGE CHANNEL of the property market: @self walks
;; to the house-agency's for-sale REGISTER (a for-sale-listings table-doc) and SCANS the
;; written table, minting a {?b availability [k for-sale]} belief for every building it
;; lists. Only once he KNOWS what is for sale (belief) does choose_home / the founding chain
;; reason over it. Replaces the old stack-browse of per-listing message docs.
;; ----------------------------------------------------------------------------

;(npc-task {@self read-listings ?register}:?rl-rel
;  (tar @excl [k for-sale-listings] @object)
;  (and
;    ; WALK: not at the register -> go to it.
;    (try
;      (role ?reg [k for-sale-listings] (= ?reg ?register)
;            (not (spatial ?reg co-located @self))
;        (when (spatial ?reg space))
;        (effects (maintain-proposal {@self go ?reg}))))
;    ; READ: at the register -> scan the table, minting an availability belief per row.
;    (try
;      (when (spatial ?register co-located @self))
;      (effects
;        (for-each-row (attr ?register writing) [/building ?baddr]
;          (o [k building] {@o address ?baddr}): ?b
;          (if -{?b address ?baddr} (then (begin-belief {?b address ?baddr})))
;          (begin-belief {?b availability [k for-sale]}))
;        (set-outcome ?rl-rel /succ)))))
