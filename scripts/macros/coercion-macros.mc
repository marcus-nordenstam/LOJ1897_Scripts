; ----------------------------------------------------------------------------
; coercion_macros.mc - the blackmail stake (coercion_pressure.mc); the press
; sequence itself lives in coercion.mc.
; ----------------------------------------------------------------------------

; (coercion-stake): the exposure-risk pressure delta a victim mints per month, as
; HE reckons it - the base window scaled by what publication would cost HIS OWN
; standing (class, self-known). begin-belief (salience ..) compounds it across months,
; walking him from bribe / confess toward the harsher grievance outlets.
(define-macro coercion-stake ()
  (* 1440
     (switch (kind (any {@self class-situation}).target)
       (on [k class-situation upper]  1.5)
       (on [k class-situation middle] 1.2)
       (else 1.0))))
