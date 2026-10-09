; ----------------------------------------------------------------------------
; enter ?space - stand inside ?space, a room, a unit or a building, through a passage or across
; its trivial link. The rungs are a preemptive-or:
;
;   inside                                       -> succeed
;   a room trivially linked to mine              -> WALK into it
;   the door he tried is locked                  -> fail
;   a passage of ?space whose far side is mine   -> cross it
;   a room of a building he is not in            -> enter the building first
;   a building whose doors he has not seen       -> go-to it; seeing it teaches them
;   inside its building, no passage into it known -> wander the building
;   in some other building                       -> exit it
;   nothing else                                 -> fail
; ----------------------------------------------------------------------------

(task {@self enter ?space}:?enter
  (tar @excl [k space|building|unit] @object)
  (cease (if (within-space @self ?space) (then (set-outcome ?enter /succ))))
  (preemptive-or
    (try (role @self (within-space @self ?space)
           (effects (set-outcome ?enter /succ))))
    (try (role @self (is-a ?space [k space])
                     (spatial (spatial @self space) trivially-linked ?space)
           (when (stand-spot-in ?space): ?spot (is-spot ?spot))
           (effects (maintain-proposal {@self WALK ?spot}))))
    (try (role @self {@self cross ? /fail /caused_by ?enter}:?cross
                     (barred-locked ?cross.target)
           (effects (set-outcome ?enter /fail))))
    (try (role ?passage (spatial ?space exits)
                    (spatial (spatial @self space) trivially-linked (spatial ?passage beyond ?space))
                    (select (score (near @self ?passage)) (policy argmax))
           (effects (maintain-proposal {@self cross ?passage}))))
    (try (role ?bldg (spatial ?space building)
           (role @self (not (is-a ?space [k building]))
                       (not (within-place @self ?bldg))
                       -{@self enter ?bldg /fail /caused_by ?enter}
             (effects (maintain-proposal {@self enter ?bldg})))))
    (try (role @self (is-a ?space [k building])
                     (unsubstantial (tolerate (spatial @self building)))
                     (empty (spatial ?space exits))
                     -{@self go-to ?space /succ /caused_by ?enter}
           (effects (maintain-proposal {@self go-to ?space}))))
    (try (role ?bldg (spatial ?space building)
           (role @self (within-place @self ?bldg)
                       -{@self wander ?bldg /succ /caused_by ?enter}
             (effects (maintain-proposal {@self wander ?bldg})))))
    (try (role ?other (spatial @self building)
           (role @self (not (within-place ?space ?other))
                       -{@self exit ?other /fail /caused_by ?enter}
             (effects (maintain-proposal {@self exit ?other})))))
    (try (effects (set-outcome ?enter /fail)))))
