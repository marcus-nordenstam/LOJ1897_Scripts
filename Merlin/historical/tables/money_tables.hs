; ----------------------------------------------------------------------------
; money_tables - authored economic config (was the C++ hsim_derive.cc income
; curve). Directory-scanned from historical/tables/ into the catalog; read by
; the money macros (money_macros.hs) via (lookup ...).
; ----------------------------------------------------------------------------

; Yearly income by job rank (the `level` rung). Funds savings accrual (accrual-net).
; A head post carries no level rung, so heads draw 0 salaried income - their standing
; is their owned business estate, not a wage. Unlisted / no job -> the lookup default 0.
(define-table income_by_level
  (fields level          income)
  (record [k trainee]    25)
  (record [k apprentice] 35)
  (record [k junior]     50)
  (record [k regular]    65)
  (record [k senior]     80))
