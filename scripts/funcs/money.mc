(include "../macros/money-macros.mc")

; (money-cost-util ?balance ?price): the FELT utility of a coin cost, scaled by the
; actor's marginal value of money - dear to a pauper (a thin carrying-cash-pile diverges toward the
; reserve floor), nothing to a lord. 0 for a free means.
(define-func money-cost-util (?balance ?price)
  (if (<= ?price 0)
      (then 0.0)
      (else (* (* /float (/ (money_reference_balance) (max /float (money_reserve_balance) ?balance)) ?price)
               (money_utility_scale)))))

; (seed-carrying-cash-pile ?h): a new human's carrying-cash-pile - an empty coin pile stowed about him,
; which he feels - and his yearly pay day. Called by every creation path: the founder pass,
; the immigrant arrival, and a birth.
(define-func seed-carrying-cash-pile (?h)
  (create-entity [k pile] (spatial ?h space /env)): ?carrying-cash-pile
  (set-attr ?carrying-cash-pile content-kind [k coin])
  (set-attr ?carrying-cash-pile count 0)
  (spatial-write ?carrying-cash-pile gripped-by ?h /env)
  (set-hidden ?carrying-cash-pile @true)
  (set-attr ?h carrying-cash-pile ?carrying-cash-pile)
  (register-annual-func (wage_payday_month) (wage_payday_day) pay-wage ?h))

; (pay-wage ?h): the year's wage into ?h's carrying-cash-pile - the income of the level his line
; on any wage book carries. Run by the calendar on his pay day; the books are the authority.
(define-func pay-wage (?h)
  (if (alive ?h)
      (then
        (for-each ?reg (env-entities [k employee-register])
          (if (table-match (attr ?reg writing) worker (name ?h) level ?level)
              (then
                (if (table-match income_by_level level ?level income ?income)
                    (then (pile-add (attr ?h carrying-cash-pile) ?income)))))))))

; (carrying-cash-pile-count ?who): the coins ?who carries, 0 when he carries none.
(define-func carrying-cash-pile-count (?who)
  (any {?who carrying-cash-pile.count ?coins=0})
  ?coins)
