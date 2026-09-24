; ----------------------------------------------------------------------------
; locate ?thing ?bldg - come to KNOW where ?thing is INSIDE ?bldg (?thing a concrete
;   object or a kind). While no ?thing is believed in ?bldg he goes into ?bldg and wanders it
; (its room-walk perceives each room's contents, teaching {?thing location} on arrival); the
; moment the location is known the maintains evaporate and locate concludes.
; ----------------------------------------------------------------------------

(npc-task {@self locate ?thing ?bldg}:?loc-rel
  (tar @excl)
  (aux [k container-structure] @object)
  (init
    (check (is-a ?bldg [k container-structure]))
    (check (grounded ?bldg)))
  (and
    (try
      (when (and (not (spatial ?thing building ?bldg))
                 (not (spatial @self building ?bldg))))
      (effects (maintain-proposal {@self go ?bldg})))
    (try
      (when (and (not (spatial ?thing building ?bldg))
                 (spatial @self building ?bldg)))
      (effects (maintain-proposal {@self wander ?bldg})))
    (try
      (when (spatial ?thing building ?bldg))
      (effects (set-outcome ?loc-rel /succ)))
    ; The search RAN OUT: this locate's own wander toured the building and concluded, and ?thing
    ; still is not in it - so it is not here, and the locate FAILED. Without this the maintain
    ; above simply re-proposes the wander for ever: locate never concludes, holds its band for the
    ; whole run, and starves every equal-band sibling through the running-incumbent tie-break.
    ; An INTERRUPTED wander is not a failed search, so this reads /succ, not any outcome.
    (try
      (when (and {@self wander ?bldg /succ /caused_by ?loc-rel}
                 (not (spatial ?thing building ?bldg))))
      (effects (set-outcome ?loc-rel /fail)))))
