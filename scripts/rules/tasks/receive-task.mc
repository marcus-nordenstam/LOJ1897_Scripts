; ----------------------------------------------------------------------------
; receive ?giver - be given something by ?giver: keep within his reach, facing him, posting
; `receiving` @self on his public bb while within it, until he holds it out (OFFER-LEFT / OFFER-RIGHT post `take` on @self's public bb), then take it with
; whichever hand is free. Coins received go into the carrying-cash-pile. Received, @self
; clears the offer off his public bb.
; ----------------------------------------------------------------------------

(task {@self receive ?giver}:?receive
  (tar [k human] @object)
  (lint-waive try-rungs-not-exclusive)
  (and
    (try
      (when (and (alive ?giver)
                 (not (spatial @self can-reach ?giver))))
      (effects (maintain-proposal {@self go-to ?giver})))
    (try
      (when (spatial @self can-reach ?giver))
      (effects (bb-public-maintain ?giver receiving @self)))
    (try
      (when (and (spatial @self can-reach ?giver)
                 (not (bb-public-any @self take))))
      (effects (maintain-proposal {@self AWAIT ?giver})))
    (try
      (when (and (spatial @self can-reach ?giver)
                 (bb-public-any @self take)))
      (effects
        (bind (bb-public-read @self take) ?thing)
        (cond
          (case {@self pocket-coins ?thing /succ /caused_by ?receive}
            (bb-public-clear @self take)
            (set-outcome ?receive /succ))
          (case (!= (spatial ?thing held-by) @self)
            (maintain-proposal {@self take ?thing}))
          (case {?thing content-kind [k coin]}
            (maintain-proposal {@self pocket-coins ?thing}))
          (else
            (bb-public-clear @self take)
            (set-outcome ?receive /succ)))))
    (try
      (when (not (alive ?giver)))
      (effects (set-outcome ?receive /fail)))))
