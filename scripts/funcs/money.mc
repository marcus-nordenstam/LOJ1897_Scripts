; (money-cost-util ?balance ?price): the FELT utility of a coin cost, scaled by the
; actor's marginal value of money - dear to a pauper (a thin purse diverges toward the
; reserve floor), nothing to a lord. 0 for a free means.
(define-func money-cost-util (?balance ?price)
  (if (<= ?price 0)
      (then 0.0)
      (else (* (* /float (/ (money_purse_reference) (max /float (money_purse_reserve) ?balance)) ?price)
               (money_utility_scale)))))
