; ----------------------------------------------------------------------------
; BUY ?goods ?vendor - the counter transaction: coins and goods move together in ONE
; act, so an interruption never leaves a paid-but-empty-handed buyer. Debit the buyer's
; coin pile by the goods' price, credit the vendor's, and edge the goods into a free
; hand - all at once. The (feasible) gate upstream (acquire) already vetted the purse;
; the (check) here is the release-armed backstop.
; ----------------------------------------------------------------------------

(include "../../macros/money-macros.mc")
(include "../../macros/collection-macros.mc")

(action {@self BUY ?goods ?vendor}:?BUY
  (motor body legs)
  (tar [k object] @object) (aux [k human] @object) (duration (seconds 1 min))
  (effects
    (check (spatial ?goods co-located @self))
    (any {@self coin-pile ?src})
    (check (>= (attr ?src count) (price ?goods)))
    (set-attr ?src count (max 0 (- (attr ?src count) (price ?goods))))
    (any {?vendor coin-pile ?vp})
    (if ?vp (then (set-attr ?vp count (+ (attr ?vp count) (price ?goods)))))
    (spatial @self right-hand): ?rh
    (if (empty (spatial ?rh grip))
        (then (spatial-write ?goods gripped-by ?rh /env))
        (else (spatial-write ?goods gripped-by (spatial @self left-hand) /env)))
    (set-outcome ?BUY /succ)))
