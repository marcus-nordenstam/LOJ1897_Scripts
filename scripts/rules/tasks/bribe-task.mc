; ----------------------------------------------------------------------------
; bribe ?victim - buy the victim's silence with cash: pay him (bribe_coins). The ended
; {@self bribe ?victim} belief IS the deed memory; the crime row records it. A dead victim ->
; abandon.
; ----------------------------------------------------------------------------

(include "../../macros/acquisition-macros.mc")

(task {@self bribe ?victim}:?bribe
  (track-skill-level [k illicit])
  (tar [k human] @object)
  (aux ?)
  (facets reportable_crime)
  (and
    (try
      (when (and (alive ?victim)
                 -{@self bribe ?victim /succ /ever}))
      (effects (maintain-proposal {@self pay ?victim (bribe_coins)})))
    (try
      (role @self {@self pay ?victim ? /succ /caused_by ?bribe}
        (effects
          (record-crime @self ?victim offer_bribe bribe @u @u)
          (set-outcome ?bribe /succ))))
    (try
      (when (or {@self pay ?victim ? /fail /caused_by ?bribe}
                (not (alive ?victim))))
      (effects (set-outcome ?bribe /fail)))))
