; ----------------------------------------------------------------------------
; household_staff.hs - the staff slots a quality home keeps filled, per home
; kind (gender-normed per period custom; female=1). Consumed by the
; (staff-household ?home /slots household_staff_slots ...) verb - a home whose
; kind matches NO row keeps no staff (the quality-home gate is this table).
; One row per SLOT: a manor keeps two maids, so two maid rows.
; ----------------------------------------------------------------------------

(define-table household_staff_slots
  (fields home_kind job female)
  (record [k manor]     [k steward]  0)
  (record [k manor]     [k cook]     1)
  (record [k manor]     [k maid]     1)
  (record [k manor]     [k maid]     1)
  (record [k manor]     [k gardener] 0)
  (record [k townhouse] [k cook]     1)
  (record [k townhouse] [k maid]     1))
