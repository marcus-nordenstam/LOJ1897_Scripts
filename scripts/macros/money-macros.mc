; ----------------------------------------------------------------------------
; money_macros - the money tunables. Money is coin piles (content-kind coin, count the
; coins), moved by the general pile acts; a man's spendable money is his carrying cash,
; the coin pile he has stowed about him, whose count he feels.
; ----------------------------------------------------------------------------

; The money curve tunables (were the C++ money_cost_util constants). money_utility_scale
; MUST match the engine k_utility_value_scale (utility_bands.h) - the felt cost lands on
; the same 0-1000 value axis every other (affect)/(cost) adjustment does.
(define-macro money_purse_reference () 100.0)   ; a comfortable liquid balance
(define-macro money_purse_reserve   () 15.0)    ; survival floor the cost diverges toward
(define-macro money_utility_scale   () 10.0)    ; = k_utility_value_scale

; The yearly pay day: the calendar pays every worker his year's wage (funcs/money.mc pay-wage).
(define-macro wage_payday_month () 12)
(define-macro wage_payday_day   () 1)

; The 0..1 wealth dimension: carried coins plus the estate a home stands for, normalised
; off the 0..100 surface (classify-wealth).
(define-macro wealth_coin_div () 120.0)   ; coins -> wealth points
(define-macro wealth_age_min () 15)       ; the age a man's wealth is first reckoned
