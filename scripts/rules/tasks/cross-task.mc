; ----------------------------------------------------------------------------
; cross ?passage - walk up to it if it is shut, open it, and step through into whatever lies beyond:
; a man goes through a door to find out what is on the other side, and seeing the space he steps
; into is how he learns it. The one block that touches a passage: nothing else proposes OPEN on
; one. A (sequence ..): every stage tests the world in its effects, so a man already at the door,
; or a door already open, falls through to the next stage. Stage 1, while the passage is shut, is
; a go-to to a stance within reach of it on his side - a crowd at the door holds him until one is
; free. The step through - the one walk the cross proposes itself - ending /succ is the cross
; done, however it ends: its proposer stops wanting it the instant he is through. A passage he
; believes locked, a shut one with no stance by it even past the crowd, an OPEN that fails, or a
; walk he cannot make fails the cross, and the go-to that proposed it tries another way.
; ----------------------------------------------------------------------------

(task {@self cross ?passage}:?cross
  (tar @excl [k passage] @object)
  (cease (if (substantial (any {@self WALK ? /succ /caused_by ?cross}))
             (then (set-outcome ?cross /succ))))
  (and
    (sequence
      (stage (bind (flip (barred ?passage) (passage-stance ?passage) @nothing) ?before)
             (effects (if (and (is-spot ?before) (not (overlaps ?before @self)))
                          (then (maintain-proposal {@self go-to ?before})))))
      (stage (when (or (not (barred ?passage)) (spatial @self can-reach ?passage)))
             (effects (if (barred ?passage)
                          (then (maintain-proposal {@self OPEN ?passage})))))
      (stage (bind (passage-spot-beyond ?passage) ?beyond)
             (effects (maintain-proposal {@self WALK ?beyond})))
      (stage (effects (set-outcome ?cross /succ))))
    (try (when (and (barred ?passage) (not (passage-stance-exists ?passage))))
         (effects (set-outcome ?cross /fail)))
    (try (role @self (or (barred-locked ?passage)
                         {@self OPEN ?passage /fail /caused_by ?cross}
                         {@self go-to ? /fail /caused_by ?cross}
                         {@self WALK ? /fail /caused_by ?cross})
           (effects (set-outcome ?cross /fail))))))
