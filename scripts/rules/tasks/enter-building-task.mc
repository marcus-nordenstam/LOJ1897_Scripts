; ----------------------------------------------------------------------------
; enter-building ?place - stand INSIDE ?place, a building or a unit, coming from outside it: he goes
; to stand by it, then crosses one of its doors - the step through takes him to the middle of the
; room beyond. Done when he stands in it and no cross of this one still runs - at once when he
; already does; every door he can cross failing, or none of it known once he stands by it, fails it.
; ----------------------------------------------------------------------------

(task {@self enter-building ?place}:?enter-building
  (tar @excl [k building|unit] @object)
  (success-cond (and (within-place @self ?place)
                     (unsubstantial (any {@self cross ? /caused_by ?enter-building}))))
  (preemptive-or
    (try (role ?door (spatial ?place exits)
                     (not (has-facet ?door nav_last_resort))
                     (in-near-room ?door)
                     -{@self cross ?door /fail /caused_by ?enter-building}
                     (select (score (near @self ?door)) (policy argmax unknown-last))
           (effects (maintain-proposal {@self cross ?door}))))
    (try (role @self -{@self go-to ?place /succ /caused_by ?enter-building}
                     -{@self go-to ?place /fail /caused_by ?enter-building}
           (effects (maintain-proposal {@self go-to ?place}))))
    (try (effects (set-outcome ?enter-building /fail)))))
