; ----------------------------------------------------------------------------
; cross ?passage ?to - from its near side, open it if he sees it shut, and step through into ?to,
; the space beyond it. The proposer fixes ?to while he stands on the near side, so the near side
; is the passage's side beyond ?to wherever he walks meanwhile. The one block that touches a
; passage: nothing else proposes OPEN on one. A (sequence ..): the head is the passage, which
; turns over once per cross; every stage tests the world in its effects, so a man already at the
; door, or a door already open, falls through to the next stage. Stage 1, while the passage is
; shut, is a go-to inside his own domain to a stance within reach of it - a crowd at the door
; holds him until one is free - and a door it meets on the way is crossed by that go-to; stage 3
; is the one short hop across. A passage he believes locked, a shut one with no stance by it even
; past the crowd, an OPEN that fails, or a step he cannot make fails the cross, and the go-to that
; proposed it tries another way. Standing in ?to is the cross done, however it ends: its proposer
; stops wanting it the instant he is through.
; ----------------------------------------------------------------------------

(task {@self cross ?passage ?to}:?cross
  (tar @excl [k passage] @object)
  (cease (if (within-space @self ?to) (then (set-outcome ?cross /succ))))
  (and
    (sequence
      (stage (bind (tolerate (spatial ?passage beyond ?to)) ?near)
             (bind (if (and (barred ?passage) (substantial ?near))
                       (then (passage-stance ?passage ?near))
                       (else @nothing))
                   ?before)
             (effects (cond
                        (case (is-spot ?before)
                          (expect (unsubstantial (spatial @self leg ?before))
                                  "cross: the near side of the passage lies outside his domain")
                          (if (not (overlaps ?before @self))
                              (then (maintain-proposal {@self go-to ?before}))))
                        ; The room before a shut door he does not know: he walks up to the door,
                        ; and the walk shows him the room.
                        (case (and (barred ?passage) (unsubstantial ?near)
                                   (not (spatial @self can-reach ?passage)))
                          (maintain-proposal {@self go-to ?passage})))))
      (stage (when (or (not (barred ?passage)) (spatial @self can-reach ?passage)))
             (effects (if (barred ?passage)
                          (then (maintain-proposal {@self OPEN ?passage})))))
      (stage (bind (passage-spot ?passage ?to) ?beyond)
             (effects (maintain-proposal {@self WALK ?beyond})))
      (stage (effects (set-outcome ?cross /succ))))
    (try (when (and (barred ?passage)
                    (substantial (tolerate (spatial ?passage beyond ?to)))
                    (not (passage-stance-exists ?passage (spatial ?passage beyond ?to)))))
         (effects (set-outcome ?cross /fail)))
    (try (role @self (or (barred-locked ?passage)
                         {@self OPEN ?passage /fail /caused_by ?cross}
                         {@self go-to ? /fail /caused_by ?cross}
                         {@self WALK ? /fail /caused_by ?cross})
           (effects (set-outcome ?cross /fail))))))
