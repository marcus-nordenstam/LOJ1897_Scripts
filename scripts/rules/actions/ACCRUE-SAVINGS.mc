; ----------------------------------------------------------------------------
; accrue-savings (action) - EXECUTION half of the yearly savings accrual (the
; deliberation is accrue-savings in thinks/hot/money_think.mc). The coin pile
; and the amount are decided think-side and ride the pattern; the body only credits
; the env pile (no belief reads), so it stays action-pure.
; ----------------------------------------------------------------------------

(include "../../macros/collection-macros.mc")

(action {@self ACCRUE-SAVINGS ?pile ?net}:?ACCRUE-SAVINGS
  (motor body legs)
  (duration 0)
  (effects
    (set-attr ?pile count (+ (attr ?pile count) ?net))
    (observe ?pile)
    (set-outcome ?ACCRUE-SAVINGS /succ)))
