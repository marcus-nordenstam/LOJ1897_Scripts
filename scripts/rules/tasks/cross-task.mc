; ----------------------------------------------------------------------------
; cross ?passage - stand before it on my side, open it if I see it shut, walk through. The one
; block that touches a passage: nothing else proposes OPEN on one. A (sequence ..): the head is
; the passage, which turns over once per cross; every stage re-tests the world, so a man already
; at the door falls through to the OPEN. Stage 1's test is his own box against a claimed spot,
; the one read that lives in a (when ..); a passage he believes locked, or that would not open,
; fails the cross.
; ----------------------------------------------------------------------------

(task {@self cross ?passage}:?cross
  (tar @excl [k passage] @object)
  (init (check (substantial (tolerate (spatial ?passage beyond (spatial @self space))))))
  (and
    (sequence
      (stage (bind (passage-spot ?passage (spatial @self space)) ?before)
             (when (not (overlaps ?before @self)))
             (effects (maintain-proposal {@self WALK ?before})))
      (stage (when (barred ?passage))
             (effects (maintain-proposal {@self OPEN ?passage})))
      (stage (bind (passage-spot ?passage (spatial ?passage beyond (spatial @self space))) ?beyond)
             (effects (maintain-proposal {@self WALK ?beyond})))
      (stage (effects (set-outcome ?cross /succ))))
    (try (role @self (or (barred-locked ?passage)
                         {@self OPEN ?passage /fail /caused_by ?cross})
           (effects (set-outcome ?cross /fail))))))
