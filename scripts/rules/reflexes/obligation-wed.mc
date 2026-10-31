; A wedding he owed is discharged once he is married to his partner, however the vow reached him,
; and the day set for it with it.
(reflex {@self spouse ?partner}
  (when {@self obligation {@self wed ?partner} ?})
  (effects
    (end-belief {@self obligation {@self wed ?partner} ?})
    (end-belief {@self wedding-day ?})))
