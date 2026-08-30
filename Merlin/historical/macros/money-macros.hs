; ----------------------------------------------------------------------------
; money_macros - the physical-cash (coin PILE) vocabulary. Money is a `pile`
; entity (content_kind = coin, count = the coins); an NPC's BALANCE is the sum of
; the counts of the coin piles it OWNS ({@self own ?pile}). Built entirely on the
; general pile ops + the `own` belief - no C++ money model.
;
; Today each NPC owns exactly one coin pile (spawned in the home); the sum-of-owned
; shape already absorbs a carried pile / a bank pile later with no change. The COUNT
; is read from the env (attr) not belief: knowing your own money is self-knowledge,
; not telepathy, and it stays correct even when a debit lands while you are away.
; ----------------------------------------------------------------------------

; The money curve tunables (were the C++ money_cost_util constants). money_utility_scale
; MUST match the engine k_utility_value_scale (utility_bands.h) - the felt cost lands on
; the same 0-1000 value axis every other (affect)/(cost) adjustment does.
(define-macro money_purse_reference () 100.0)   ; a comfortable liquid balance
(define-macro money_purse_reserve   () 15.0)    ; survival floor the cost diverges toward
(define-macro money_utility_scale   () 10.0)    ; = k_utility_value_scale

; (money-cost-util ?balance ?price): the FELT utility of a coin cost, scaled by the
; actor's marginal value of money - dear to a pauper (a thin purse diverges toward the
; reserve floor), nothing to a lord. 0 for a free means.
(define-macro money-cost-util (?balance ?price)
  (if (<= ?price 0)
      (then 0)
      (else (* (* (/ (money_purse_reference) (max (money_purse_reserve) ?balance)) ?price)
               (money_utility_scale)))))

; (coin-balance ?who): the coins ?who BELIEVES it has - the perceived count of its
; coin pile, read through the {@self coin_pile <pile>} pointer's `.count` chain. The
; count belief mirrors the entity's real count attr the moment ?who observes the pile
; (seed / accrual / spend all observe), so this is belief-honest and legal in a (when).
(define-macro coin-balance (?who)
  (if {?who coin_pile.count ?}
      (then (any {?who coin_pile.count ?}).target)
      (else 0)))

; ---- the economic model (was hsim_derive.cc, purged) -----------------------

; (job-income ?who): the yearly salary of ?who's job (0 if unsalaried / no job). The
; job.salary belief IS the income - set at hire from income_by_level (money_tables.hs).
(define-macro job-income (?who)
  (if {?who job.salary ?}
      (then (any {?who job.salary ?}).target)
      (else 0)))

; (building-worth-of ?b): the estate worth a building contributes to wealth (was
; C++ building_estate_worth). A rented / lower-class residence counts nothing; any
; other owned building is a business premises unless it is a named quality dwelling.
(define-macro building-worth-of (?b)
  (if (is-a ?b [k manor])                      (then 40)
  (else (if (is-a ?b [k townhouse])            (then 30)
  (else (if (is-a ?b [k farmhouse])            (then 18)
  (else (if (is-a ?b [k residential_building]) (then 0)
            (else 25)))))))))

; (estate-worth ?who): the worth of ?who's home dwelling (B-simplify: the home only,
; via the single-valued {@self home <bldg>} pointer; a rented rowhouse counts 0 by
; building-worth-of). Owned business premises are not counted in this pass.
(define-macro estate-worth (?who)
  (if {?who home ?}
      (then (building-worth-of (any {?who home ?}).target))
      (else 0)))

; (accrual-net ?who): the whole coins ?who saves in a year - salaried income plus a
; property owner's bonus. Kept INTEGER (coin counts are whole coins; there is no
; floor/round op), so the savings-rate multiplier and the float gambling drain of the
; old bank model are dropped (consistent with the coins-not-proxies wealth model).
(define-macro accrual_owner_bonus () 30)
(define-macro accrual-net (?who)
  (+ (job-income ?who)
     (if (> (count (every {?who own [k building]})) 0) (then (accrual_owner_bonus)) (else 0))))

; (wealth-from ?who ?coins) / (wealth-of ?who): the 0..1 wealth dimension - liquid
; coins plus owned estate, normalised off the 0..100 surface (was C++ classify_wealth,
; minus the income / creditor / gambling PROXY terms now that liquid wealth is modelled
; directly). wealth-from takes an explicit coin figure so the accrual driver can classify
; off its PROJECTED post-credit balance (a think reads pre-credit coins); wealth-of reads
; the believed balance for any other caller.
(define-macro wealth_coin_div () 120.0)   ; coins -> wealth points
(define-macro wealth-from (?who ?coins)
  (/ (clamp (+ (/ ?coins (wealth_coin_div)) (estate-worth ?who)) 0 100) 100))
