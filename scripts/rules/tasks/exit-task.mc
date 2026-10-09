; ----------------------------------------------------------------------------
; exit ?place - stand outside ?place, a room, a unit or a building, in ?place's space as he
; has seen it: a unit's or a building's is the exterior the building stands in. The rungs are a
; preemptive-or:
;
;   outside                                      -> succeed
;   the door he tried is locked                  -> fail
;   my room's outer wall stands open             -> WALK out through it
;   an exit whose inner room is trivially mine   -> cross it
;   the nearest exit's inner room                -> enter it first
;   no exit known                                -> wander ?place
;   nothing else                                 -> fail
; ----------------------------------------------------------------------------

(task {@self exit ?place}:?exit
  (tar @excl [k space|building|unit] @object)
  (cease (if (not (within-space @self ?place)) (then (set-outcome ?exit /succ))))
  (preemptive-or
    (try (role @self (not (within-space @self ?place))
           (effects (set-outcome ?exit /succ))))
    (try (role @self {@self cross ? /fail /caused_by ?exit}:?cross
                     (barred-locked ?cross.target)
           (effects (set-outcome ?exit /fail))))
    (try (role ?outside (spatial ?place space)
           (role @self (spatial (spatial @self space) trivially-linked ?outside)
             (when (stand-spot-in ?outside): ?spot (is-spot ?spot))
             (effects (maintain-proposal {@self WALK ?spot})))))
    (try (role ?outside (spatial ?place space)
           (role ?passage (spatial ?place exits)
                      (spatial (spatial @self space) trivially-linked (spatial ?passage beyond ?outside))
                      (select (score (near @self ?passage)) (policy best))
             (effects (maintain-proposal {@self cross ?passage})))))
    (try (role ?outside (spatial ?place space)
           (role ?passage (spatial ?place exits)
                      -{@self enter (spatial ?passage beyond ?outside) /fail /caused_by ?exit}
                      (select (score (near @self ?passage)) (policy best))
             (effects (maintain-proposal {@self enter (spatial ?passage beyond ?outside)})))))
    (try (role @self -{@self wander ?place /succ /caused_by ?exit}
           (effects (maintain-proposal {@self wander ?place}))))
    (try (when @true)
         (effects (set-outcome ?exit /fail)))))
