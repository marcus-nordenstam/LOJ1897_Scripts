; ----------------------------------------------------------------------------
; acquisition_macros - shared vocabulary for the acquire / steal task chain: the
; concealment predicates a thief gates his grip on, plus the agent fee a hirer pays.
; Coin resolution / cost live in money_macros.mc; pile mutation in collection_macros.mc.
; ----------------------------------------------------------------------------



; (procure_fee): the coins a hired procurer takes on top of the item's price. Tunable.
(define-macro procure_fee () 20)

; (bribe_coins): the coins a briber counts out of his carrying cash for his victim. Tunable.
(define-macro bribe_coins () 5)
