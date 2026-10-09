; ----------------------------------------------------------------------------
; bribe ?victim - buy the victim's silence with cash. @self counts (bribe_coins) out of his
; carrying cash into his hand and HANDS IT OVER via give: the give task reaches the
; co-present victim and OFFERs it hand-to-hand. Private, no cross-mind write; the punctual
; OFFER is visually unwitnessed - the point of a bribe. The ended {@self bribe ?victim}
; belief IS the deed memory; the crime row records it. A dead victim -> abandon.
; ----------------------------------------------------------------------------

(include "../../macros/acquisition-macros.mc")

(task {@self bribe ?victim}:?bribe
  (track-skill-level [k illicit])
  (tar [k human] @object)
  (aux ?)
  (facets reportable_crime)
  (and
    (try
      (role ?counted [k pile] {?counted content-kind [k coin]} (= (spatial ?counted held-by) @self)
        (when (and (alive ?victim)
                   -{@self bribe ?victim /succ /ever}))
        (declare-utility errand)
        (effects (maintain-proposal {@self give ?counted ?victim}))))
    (try
      (role ?cash {@self carrying-cash ?cash} {?cash count ?cash-count}
        (no-role [k pile] {?norole content-kind [k coin]} (= (spatial ?norole held-by) @self))
        (when (and (alive ?victim)
                   -{@self bribe ?victim /succ /ever}
                   -{@self give ? ?victim}
                   (>= ?cash-count (bribe_coins))
                   (empty (spatial (spatial @self right-hand) grip))))
        (effects (maintain-proposal {@self PILE-SPLIT ?cash (bribe_coins)}))))
    (try
      (when {@self give ? ?victim /succ /caused_by ?bribe})
      (effects
        (record-crime @self ?victim offer_bribe bribe @u @u)
        (set-outcome ?bribe /succ)))
    (try
      (when (not (alive ?victim)))
      (effects (set-outcome ?bribe /fail)))))
