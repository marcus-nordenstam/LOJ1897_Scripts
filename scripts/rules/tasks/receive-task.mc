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
    ; Held out -> taken; coins taken -> pocketed; anything else held -> received.
    (try
      (when (and (spatial @self can-reach ?giver)
                 (bb-public-read @self take): ?thing
                 {@self pocket-coins ?thing /succ /caused_by ?receive}))
      (effects
        (bb-public-clear @self take)
        (set-outcome ?receive /succ)))
    (try
      (when (and (spatial @self can-reach ?giver)
                 (bb-public-read @self take): ?thing
                 -{@self pocket-coins ?thing /succ /caused_by ?receive}
                 (!= (spatial ?thing held-by) @self)))
      (effects (maintain-proposal {@self take ?thing})))
    (try
      (when (and (spatial @self can-reach ?giver)
                 (bb-public-read @self take): ?thing
                 -{@self pocket-coins ?thing /succ /caused_by ?receive}
                 (= (spatial ?thing held-by) @self)
                 {?thing content-kind [k coin]}))
      (effects (maintain-proposal {@self pocket-coins ?thing})))
    (try
      (when (and (spatial @self can-reach ?giver)
                 (bb-public-read @self take): ?thing
                 (= (spatial ?thing held-by) @self)
                 -{?thing content-kind [k coin]}))
      (effects
        (bb-public-clear @self take)
        (set-outcome ?receive /succ)))
    (try
      (when (not (alive ?giver)))
      (effects (set-outcome ?receive /fail)))))
