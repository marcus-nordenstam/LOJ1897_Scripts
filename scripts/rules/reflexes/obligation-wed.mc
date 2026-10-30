; A wedding he owed is discharged once he has wed, and the day set for it with it.
(reflex {@self wed ?partner /succ}
  (when {@self obligation {@self wed ?partner} ?})
  (effects
    (end-belief {@self obligation {@self wed ?partner} ?})
    (end-belief {@self wedding-day ?})))
