; ----------------------------------------------------------------------------
; formulaic-macros.mc - where a (formulaic ..) message keeps what, for every func that reads one
; (funcs/conversation.mc, funcs/speech.mc).
; ----------------------------------------------------------------------------

; A (formulaic <riders> <category> ..)'s category: field 0 is the name, 1 the rider list.
(define-macro k-formulaic-category-field () 2)
; ... field 3 its key (greeting, player_talk, authority ..), and an authority introduction's
; field 4 the kind of the office it introduces.
(define-macro k-formulaic-key-field () 3)
(define-macro k-formulaic-office-field () 4)
