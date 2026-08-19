; ----------------------------------------------------------------------------
; bribe ?victim - buy the victim's silence with cash. @self conjures a coin (the single
; buildable unit of cash - a real gripped prop) and HANDS IT OVER via give: the give task
; takes the coin, reaches the co-present victim, and OFFERs it hand-to-hand. Private, no
; cross-mind write; the punctual OFFER is visually unwitnessed - the point of a bribe. The
; ended {@self bribe ?victim} belief IS the deed memory; the crime-ledger row records it.
; A dead victim -> abandon.
; ----------------------------------------------------------------------------

(npc-task {@self bribe ?victim}:?bribe-rel
  (tar human)
  (aux ?)
  (facets reportable_crime)
  (and
    (try
      (role ?coin [k coin] (co-present ?coin @self))
      (when (and (alive ?victim)
                 (none {@self bribe ?victim /succ /ever})))
      (utility errand)
      (effects (maintain-proposal {@self give ?coin ?victim})))
    (try
      (when (and (alive ?victim)
                 (none {@self bribe ?victim /succ /ever})
                 (not (has-proposal {@self give ? ?victim}))))
      (effects (create-entity [k coin] (qual location (location @self)))))
    (try
      (when (any {@self give ? ?victim /succ /caused_by ?bribe-rel}))
      (effects
        (crime-ledger-append @self ?victim offer_bribe bribe @u @u)
        (set-outcome ?bribe-rel succ)))
    (try
      (when (not (alive ?victim)))
      (effects (set-outcome ?bribe-rel fail)))))
