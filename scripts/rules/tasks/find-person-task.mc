; ----------------------------------------------------------------------------
; find-person ?person [?place] - come to know where ?person is. Given ?place, a building or a unit,
; he wanders it; else he wanders, in turn, the places he would find him: the premises he last saw
; him in, his home, his workplace, the house at his address. Knowing his box or his space again
; concludes it; a place searched without sight of him, or one he cannot get into, is struck off,
; and none left fails it. Preparation: finding the man is never what a pursuit of him was for.
; ----------------------------------------------------------------------------

(task {@self find-person ?person ?place}:?find-person
  (tar [k human] @object)
  (aux ?)
  (preparatory)
  (success-cond (placed ?person))
  (preemptive-or
    (try (belief (substantial ?place) (not (premises-searched ?place ?find-person))
           (effects (maintain-proposal {@self wander ?place} /tolerate-fail))))
    (try (belief (substantial ?place)
           (effects (set-outcome ?find-person /fail))))
    (try (role ?seen (spatial ?person space /most-recent-memory)
           (when (place-holding ?seen): ?last
                 (substantial ?last)
                 (not (premises-searched ?last ?find-person)))
           (effects (maintain-proposal {@self wander ?last} /tolerate-fail))))
    (try (role ?home {?person home ?home}
                     (grounded ?home)
                     (one-premises ?home)
                     (not (premises-searched ?home ?find-person))
           (effects (maintain-proposal {@self wander ?home} /tolerate-fail))))
    (try (role ?job {?person job ?job}
           (role ?org {?job org ?org}
             (role ?wp {?org workplace ?wp}
               (when (place-holding ?wp): ?work
                     (substantial ?work)
                     (grounded ?work)
                     (not (premises-searched ?work ?find-person)))
               (effects (maintain-proposal {@self wander ?work} /tolerate-fail))))))
    (try (belief (substantial (seen-house-of ?person))
                     (one-premises (seen-house-of ?person))
                     (not (premises-searched (seen-house-of ?person) ?find-person))
           (effects (maintain-proposal {@self wander (seen-house-of ?person)} /tolerate-fail))))
    (try (effects (set-outcome ?find-person /fail)))))
