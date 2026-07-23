; ----------------------------------------------------------------------------
; prices.hs - the coin cost of a MEANS at a venue, as authored config (a
; (define-table ...), read by the (price <venue>) op via hse_table_lookup). Keyed
; by the venue's KIND: a venue kind ABSENT from this table is free (price 0), so a
; home / workplace meal carries no cost by construction - the (cost money ...) /
; (feasible ...) clauses fold to nothing there with no special-casing.
;
; Prices are in COIN units, on the same scale as bank_balance (~0..150); the engine
; converts a coin price into felt utility per the actor's marginal value of money
; (money_cost_util), so the same price stings a pauper and barely touches a lord.
; ----------------------------------------------------------------------------

(define-table prices
  (fields venue                    price)
  (record [k building pub]         8)
  (record [k building restaurant]  15))
