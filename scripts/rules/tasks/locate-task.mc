; ----------------------------------------------------------------------------
; locate ?thing ?bldg - come to KNOW where ?thing is INSIDE ?bldg (?thing a concrete
;   object or a kind, a thing in it or a room of it). While no ?thing is believed in ?bldg he goes into ?bldg and wanders it
; (its room-walk perceives each room's contents, teaching {?thing location} on arrival); the
; moment the location is known the maintains evaporate and locate concludes.
; ----------------------------------------------------------------------------

; ?thing is known inside ?bldg: a thing placed in it, or a room of it.
(define-func locate-known (?thing ?bldg)
  (or (within-place ?thing ?bldg)
      (spatial ?bldg room ?thing)))

(task {@self locate ?thing ?bldg}:?locate
  (tar @excl)
  (aux [k building|unit] @object)
  (init
    (check (or (is-a ?bldg [k building]) (is-a ?bldg [k unit])))
    (check (grounded ?bldg)))
  (and
    (try
      (when (and (not (locate-known ?thing ?bldg))
                 (not (within-place @self ?bldg))))
      (effects (maintain-proposal {@self go ?bldg})))
    (try
      (when (and (not (locate-known ?thing ?bldg))
                 (within-place @self ?bldg)))
      (effects (maintain-proposal {@self wander ?bldg})))
    (try
      (when (locate-known ?thing ?bldg))
      (effects (set-outcome ?locate /succ)))
    ; The search RAN OUT: this locate's own wander toured the building and concluded, and ?thing
    ; still is not in it - so it is not here, and the locate FAILED. Without this the maintain
    ; above simply re-proposes the wander for ever: locate never concludes, holds its band for the
    ; whole run, and starves every equal-band sibling through the running-incumbent tie-break.
    ; An INTERRUPTED wander is not a failed search, so this reads /succ, not any outcome.
    (try
      (when (and {@self wander ?bldg /succ /caused_by ?locate}
                 (not (locate-known ?thing ?bldg))))
      (effects (set-outcome ?locate /fail)))))
