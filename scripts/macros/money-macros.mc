; ----------------------------------------------------------------------------
; money_macros - the physical-cash (coin PILE) vocabulary. Money is a `pile`
; entity (content-kind = coin, count = the coins); an NPC's BALANCE is the sum of
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



; ---- the economic model (was hsim_derive.cc, purged) -----------------------




; (accrual-net ?who): the whole coins ?who saves in a year - salaried income plus a
; property owner's bonus. Kept INTEGER (coin counts are whole coins; there is no
; floor/round op), so the savings-rate multiplier and the float gambling drain of the
; old bank model are dropped (consistent with the coins-not-proxies wealth model).
(define-macro accrual_owner_bonus () 30)

; (wealth-from ?who ?coins) / (wealth-of ?who): the 0..1 wealth dimension - liquid
; coins plus owned estate, normalised off the 0..100 surface (was C++ classify_wealth,
; minus the income / creditor / gambling PROXY terms now that liquid wealth is modelled
; directly). wealth-from takes an explicit coin figure so the accrual driver can classify
; off its PROJECTED post-credit balance (a think reads pre-credit coins); wealth-of reads
; the believed balance for any other caller.
(define-macro wealth_coin_div () 120.0)   ; coins -> wealth points
