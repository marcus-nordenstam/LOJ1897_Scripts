(include "../macros/money-macros.mc")

; (money-cost-util ?balance ?price): the FELT utility of a coin cost, scaled by the
; actor's marginal value of money - dear to a pauper (a thin purse diverges toward the
; reserve floor), nothing to a lord. 0 for a free means.
(define-func money-cost-util (?balance ?price)
  (if (<= ?price 0)
      (then 0.0)
      (else (* (* /float (/ (money_purse_reference) (max /float (money_purse_reserve) ?balance)) ?price)
               (money_utility_scale)))))

; (seed-carrying-cash ?h): a new human's carrying cash - an empty coin pile stowed about him,
; which he feels - and his yearly pay day. Called by every creation path: the founder pass,
; the immigrant arrival, and a birth.
(define-func seed-carrying-cash (?h)
  (create-entity [k pile] (spatial ?h space /env)): ?cash
  (set-attr ?cash content-kind [k coin])
  (set-attr ?cash count 0)
  (spatial-write ?cash gripped-by ?h /env)
  (set-hidden ?cash @true)
  (set-attr ?h carrying-cash ?cash)
  (register-annual-func (wage_payday_month) (wage_payday_day) pay-wage ?h))

; (pay-wage ?h): the year's wage into ?h's carrying cash - the income of the level his line
; on any wage book carries. Run by the calendar on his pay day; the books are the authority.
(define-func pay-wage (?h)
  (if (alive ?h)
      (then
        (for-each ?reg (env-entities [k employee-register])
          (if (table-match (attr ?reg writing) worker (name ?h) level ?level)
              (then
                (if (table-match income_by_level level ?level income ?income)
                    (then (pile-add (attr ?h carrying-cash) ?income)))))))))
