; ----------------------------------------------------------------------------
; locate ?thing ?place - come to KNOW where ?thing is INSIDE ?place, one premises (?thing a concrete
;   object or a kind, a thing in it or a room of it). While no ?thing is believed in ?place he goes into ?place and wanders it
; (its room-walk perceives each room's contents, teaching {?thing location} on arrival); the
; moment the location is known the maintains evaporate and locate concludes.
; ----------------------------------------------------------------------------

; ?thing is known inside ?place: a thing placed in it, or a room of it. An object must be seen:
; a room known only by its address is in the building and still nowhere he can walk to.
(define-func locate-known (?thing ?place)
  (and (flip (is-object ?thing) (grounded ?thing) @true)
       (or (within-place ?thing ?place)
           (spatial ?place room ?thing))))

(task {@self locate ?thing ?place}:?locate
  (tar @excl)
  (aux [k building|unit] @object)
  (init
    (check (one-premises ?place))
    (check (grounded ?place)))
  (and
    (try
      (when (and (not (locate-known ?thing ?place))
                 (not (within-place @self ?place))))
      (effects (maintain-proposal {@self go-to ?place})))
    (try
      (when (and (not (locate-known ?thing ?place))
                 (within-place @self ?place)))
      (effects (maintain-proposal {@self wander ?place})))
    (try
      (when (locate-known ?thing ?place))
      (effects (set-outcome ?locate /succ)))
    ; The search RAN OUT: this locate's own wander toured the building and concluded, and ?thing
    ; still is not in it - so it is not here, and the locate FAILED. Without this the maintain
    ; above simply re-proposes the wander for ever: locate never concludes, holds its band for the
    ; whole run, and starves every equal-band sibling through the running-incumbent tie-break.
    ; An INTERRUPTED wander is not a failed search, so this reads /succ, not any outcome.
    (try
      (when (and {@self wander ?place /succ /caused_by ?locate}
                 (not (locate-known ?thing ?place))))
      (effects (set-outcome ?locate /fail)))))
