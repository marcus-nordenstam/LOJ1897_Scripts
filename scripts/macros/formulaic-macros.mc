; ----------------------------------------------------------------------------
; formulaic-macros.mc - where a (formulaic ..) message keeps what, for every func that reads one
; (funcs/conversation.mc, funcs/speech.mc).
; ----------------------------------------------------------------------------

; Fields read out of a message (a test of its shape matches it positionally instead): field 0 is
; the name, 1 the rider list, 2 a (msg ..)'s first content, and of a (formulaic <riders> <category>
; ..) field 3 its key (greeting, player_talk, authority ..) and an authority introduction's field 4
; the kind of the office it introduces.
(define-macro k-msg-first-content-field () 2)
(define-macro k-formulaic-key-field () 3)
(define-macro k-formulaic-office-field () 4)
