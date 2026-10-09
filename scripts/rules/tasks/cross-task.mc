; ----------------------------------------------------------------------------
; cross ?passage ?to - from its near side, open it if he sees it shut, and step through into ?to,
; the space beyond it. The proposer fixes ?to while he stands on the near side, so the near side
; is the passage's side beyond ?to wherever he walks meanwhile. The one block that touches a
; passage: nothing else proposes OPEN on one. A (sequence ..): the head is the passage, which
; turns over once per cross; every stage tests the world in its effects, so a man already at the
; door, or a door already open, falls through to the next stage. Stage 1 is a go-to, inside his own domain, so a door it meets on the way
; is crossed by that go-to; stage 3 is the one short hop across. A passage he believes locked, an
; OPEN that fails, or a step he cannot make fails the cross.
; ----------------------------------------------------------------------------

(task {@self cross ?passage ?to}:?cross
  (tar @excl [k passage] @object)
  (init (check (substantial (tolerate (spatial ?passage beyond ?to)))))
  (and
    (sequence
      (stage (bind (passage-spot ?passage (spatial ?passage beyond ?to)) ?before)
             (effects (expect (unsubstantial (spatial @self leg ?before))
                              "cross: the near side of the passage lies outside his domain")
                      (if (not (overlaps ?before @self))
                          (then (maintain-proposal {@self go-to ?before})))))
      (stage (effects (if (barred ?passage)
                          (then (maintain-proposal {@self OPEN ?passage})))))
      (stage (bind (passage-spot ?passage ?to) ?beyond)
             (effects (maintain-proposal {@self WALK ?beyond})))
      (stage (effects (set-outcome ?cross /succ))))
    (try (role @self (or (barred-locked ?passage)
                         {@self OPEN ?passage /fail /caused_by ?cross}
                         {@self go-to ? /fail /caused_by ?cross}
                         {@self WALK ? /fail /caused_by ?cross})
           (effects (set-outcome ?cross /fail))))))
