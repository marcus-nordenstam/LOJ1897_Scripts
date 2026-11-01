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

; Days after catching up with a friend before loneliness sends @self to him again.
(define-macro catch-up-interval-days () 1)

; The most a conversation seats: an NPC's hail to a man in a full one is turned down.
(define-macro conversation-size-max () 5)

; The warmth @self feels toward a man on learning they share an interest.
(define-macro shared-interest-warmth () 0.4)





