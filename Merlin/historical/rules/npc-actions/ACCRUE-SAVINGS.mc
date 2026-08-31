; ----------------------------------------------------------------------------
; accrue_savings (npc-action) - EXECUTION half of the yearly savings accrual (the
; deliberation is accrue_savings in npc-think/hot/money_think.hs). The coin pile
; and the amount are decided think-side and ride the pattern; the body only credits
; the env pile (no belief reads), so it stays action-pure.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")
(include "../../macros/collection-macros.mc")

(npc-action {@self ACCRUE_SAVINGS ?pile ?net}
  (duration 0)
  (effects
    (pile-add ?pile ?net)
    (observe ?pile)
    (set-outcome {@self ACCRUE_SAVINGS ?pile ?net} /succ)))
