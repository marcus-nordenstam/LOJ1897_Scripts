; ----------------------------------------------------------------------------
; locate ?thing ?bldg - come to KNOW where ?thing is INSIDE ?bldg (?thing a concrete
; object or a kind). While no ?thing is believed in ?bldg, wander ?bldg (its room-walk
; perceives each room's contents, teaching {?thing location} on arrival); the moment the
; location is known the wander maintain evaporates and locate concludes.
;
; and: the two tries are complementary on (spatial ?thing building ?bldg).
; ----------------------------------------------------------------------------

(npc-task {@self locate ?thing ?bldg}:?loc-rel
  (tar @excl)
  (aux structure)
  (and
    (try
      (when (not (spatial ?thing building ?bldg)))
      (effects (maintain-proposal {@self wander ?bldg})))
    (try
      (when (spatial ?thing building ?bldg))
      (effects (set-outcome ?loc-rel /succ)))))
