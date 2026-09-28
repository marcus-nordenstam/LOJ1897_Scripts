; ----------------------------------------------------------------------------
; social_macros.mc - relationship-query define-macros.
;
;
; Whom a mind knows, and how well, is read off its bonds: {@self (closeness-labels <tier>) ?x}
; holds for anyone @self holds a bond with at least that close (acquaintance = knows them at
; all), and {@self (kin-labels) ?x} for blood relations. Both folds are declared on the bond
; labels in states.mon ((closeness <tier>), (kin)).
; ----------------------------------------------------------------------------



; The education a man must hold to read and write.
(define-macro literacy-education-min () 0.30)





