; ----------------------------------------------------------------------------
; BUY ?goods ?vendor - the counter transaction: coins and goods move together in ONE
; act, so an interruption never leaves a paid-but-empty-handed buyer. Debit the buyer's
; coin pile by the goods' price, credit the vendor's, and edge the goods into a free
; hand - all at once. The (feasible) gate upstream (acquire) already vetted the purse;
; the (check) here is the release-armed backstop.
; ----------------------------------------------------------------------------

(include "../../macros/money-macros.mc")
(include "../../macros/collection-macros.mc")

(npc-action {@self BUY ?goods ?vendor}:?buy-act-rel
  (tar object) (aux human) (duration 1)
  (effects
    (check (spatial ?goods co-located @self))
    (check (>= (coin-balance @self) (price ?goods)))
    (any {@self coin-pile ?src})
    (pile-take ?src (price ?goods))
    (any {?vendor coin-pile ?vp})
    (if ?vp (then (pile-add ?vp (price ?goods))))
    (if (empty (spatial (spatial @self right-hand) grip))
        (then (spatial-write ?goods gripped-by (spatial @self right-hand) /env))
        (else (spatial-write ?goods gripped-by (spatial @self left-hand) /env)))
    (set-outcome ?buy-act-rel /succ)))
