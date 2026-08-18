; ----------------------------------------------------------------------------
; locate ?thing ?bldg - come to KNOW where ?thing is INSIDE ?bldg (?thing a concrete
; object or a kind). While no ?thing is believed in ?bldg, wander ?bldg (its room-walk
; perceives each room's contents, teaching {?thing location} on arrival); the moment the
; location is known the wander maintain evaporates and locate concludes.
;
; and: the two tries are complementary on (in-building ?thing ?bldg).
; ----------------------------------------------------------------------------

(npc-task {@self locate ?thing ?bldg}:?loc
  (tar @excl)
  (aux structure)
  (and
    (try
      (when (not (in-building ?thing ?bldg)))
      (effects (maintain-proposal {@self wander ?bldg})))
    (try
      (when (in-building ?thing ?bldg))
      (effects (set-outcome ?loc succ)))))
