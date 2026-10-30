; ----------------------------------------------------------------------------
; find-thing ?thing [?place] - come to know where ?thing is: an object, or any thing of a kind.
; Given ?place, a building or a unit, he wanders it until he knows ?thing in it; else he wanders the
; premises he last saw it in, then the house at its address. Knowing it concludes it; a place
; searched without it, or one he cannot get into, is struck off, and none left fails it.
; ----------------------------------------------------------------------------

; He knows ?thing - in ?place when one is given. An object must be seen there: one known only by
; report is still nowhere he can walk to.
(define-func find-thing-known (?thing ?place)
  (flip (substantial ?place)
        (and (flip (is-object ?thing) (grounded ?thing) @true)
             (within-place ?thing ?place))
        (placed ?thing)))

(task {@self find-thing ?thing ?place}:?find-thing
  (tar ?)
  (aux ?)
  (preparatory)
  (success-cond (find-thing-known ?thing ?place))
  (preemptive-or
    (try (role @self (substantial ?place) (not (premises-searched ?place ?find-thing))
           (effects (maintain-proposal {@self wander ?place}))))
    (try (role @self (substantial ?place)
           (effects (set-outcome ?find-thing /fail))))
    (try (role ?seen (spatial ?thing space /most-recent-memory)
           (when (place-holding ?seen): ?last
                 (substantial ?last)
                 (not (premises-searched ?last ?find-thing)))
           (effects (maintain-proposal {@self wander ?last}))))
    (try (role @self (substantial (seen-house-of ?thing))
                     (one-premises (seen-house-of ?thing))
                     (not (premises-searched (seen-house-of ?thing) ?find-thing))
           (effects (maintain-proposal {@self wander (seen-house-of ?thing)}))))
    (try (effects (set-outcome ?find-thing /fail)))))
