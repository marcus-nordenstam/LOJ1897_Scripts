; ----------------------------------------------------------------------------
; locate-person ?person - come to know again where ?person is, whose whereabouts the mind has lost. He searches
; the places he would find him: the building he last saw him in, his home, his workplace - each
; with locate, which goes into it and wanders it. Knowing his box or his space again concludes it; a search of
; every such place that shows him nowhere fails it. Preparation: finding the man is never what a
; pursuit of him was for.
; ----------------------------------------------------------------------------

(task {@self locate-person ?person}:?locate-person
  (tar [k human] @object)
  (preparatory)
  (preemptive-or
    (try (role @self (or (substantial (tolerate (spatial ?person bounds)))
                         (substantial (tolerate (spatial ?person space))))
           (effects (set-outcome ?locate-person /succ))))
    (try (role ?seen (spatial ?person space /most-recent-memory)
                     -{@self locate ?person (place-holding ?seen) /fail /caused_by ?locate-person}
           (when (place-holding ?seen): ?place (substantial ?place))
           (effects (maintain-proposal {@self locate ?person ?place}))))
    (try (role ?home {?person home ?home}
                     (grounded ?home)
                     -{@self locate ?person ?home /fail /caused_by ?locate-person}
           (effects (maintain-proposal {@self locate ?person ?home}))))
    (try (role ?job {?person job ?job}
           (role ?org {?job org ?org}
             (role ?wp {?org workplace ?wp}
                       -{@self locate ?person (place-holding ?wp) /fail /caused_by ?locate-person}
               (when (place-holding ?wp): ?place (substantial ?place) (grounded ?place))
               (effects (maintain-proposal {@self locate ?person ?place}))))))
    (try (effects (set-outcome ?locate-person /fail)))))
