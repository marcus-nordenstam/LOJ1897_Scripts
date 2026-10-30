; ----------------------------------------------------------------------------
; find-building - the venue-discovery search. A seek rule PROPOSES (maintain-proposal)
; the {@self find-building [k building <kind>] ?region} task; its rungs cover the region one
; structure at a time: go to the closest structure he has not observed, and look at it there.
; It succeeds once he knows the sought building, and fails ONLY once every structure in the region
; is observed without it. Searching STRUCTURES, not the sought kind, keeps it non-telepathic.
; ----------------------------------------------------------------------------

; What the search was for, once @self knows where it stands: a building of the sought KIND
; whose address he holds, or the house he has seen at the sought PLACE's premises. @nothing
; while it is still out there.
(define-func find-building-found (?sought)
  (bind @nothing ?found)
  (if (is-kind ?sought)
    (then
      (if (any {?sought address}): ?kind-address
        (then (bind ?kind-address.subject ?found))))
    (else
      (if (any {?sought address}): ?address
        (then (bind (seen-premises-at (address-premises ?address.target)) ?found)))))
  ?found)

(task {@self find-building ?sought ?region}:?find-building
  ; The frontier IS the exception: covering unexplored ground means asking the world what
  ; is out there that @self has not seen yet. Signed off deliberately.
  (lint-waive env-read-outside-action)
  (tar ?)
  (aux ?)
  (preparatory)
  (success-cond (substantial (find-building-found ?sought)))
  (preemptive-or
    (try
      (when (and (latch-eval (closest-unobserved [k building] ?region): ?dest)
                 (substantial ?dest)
                 (observed ?dest /not)
                 (travel-spot (spatial ?dest bounds /env)): ?spot
                 {@self go-to ?spot /succ /caused_by ?find-building}))
      (effects (observe ?dest)))
    (try
      (when (and (latch-eval (closest-unobserved [k building] ?region): ?dest)
                 (substantial ?dest)
                 (observed ?dest /not)
                 (travel-spot (spatial ?dest bounds /env)): ?spot))
      (effects
        (check (is-spot ?spot))
        (maintain-proposal {@self go-to ?spot})))
    (try
      (when (unsubstantial (closest-unobserved [k building] ?region)))
      (effects (set-outcome ?find-building /fail)))))
