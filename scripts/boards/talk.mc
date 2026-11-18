; ----------------------------------------------------------------------------
; The talk's boards (funcs/talk.mc). bbk-line, on a talk's public board, is its LOG: one record per
; line said in it, keyed by the line (the abs SAY), in the order said; the line it replies to rides
; on its message (the reply-to rider). bbk-called, on a hailer's own board, names the talk whose board his hail
; put a man on, keyed by that man, until the hail is over. bbk-hail-answer, on a hailer's own public
; board, is what each man he hailed answered, keyed by that man: taken or turned-down, cleared when
; he hails him again. bbk-hail, on a talk's public board, is a hail called in that talk, keyed by the man
; called: its caller, the opening he called with, and its state - called from the instant the caller's
; opening is said, taken or turned-down once the man called has answered - until the caller's hail is
; over and he clears it.
; bbk-reply-state, on a
; man's own object of a talk, is what he makes of each line said to him there that is owed a reply
; or waits on what its speaker meant, keyed by the line in the order heard: its state - owed (heard,
; a reply owed once nothing blocks it), unowed (it only waits to be understood), due (he is obliged
; to reply now), given - and blocked-on, the then, there, he, she or it its talk gives no meaning, or
; the man he must first ask which one he is.
; ----------------------------------------------------------------------------

(bb-key bbk-line (/scope public) (/shape sequence) (/bound 32) (/lifetime host))
(bb-key bbk-called (/scope private) (/shape map) (/fields talk) (/lifetime sleep))
(bb-key bbk-hail-answer (/scope public) (/shape map) (/fields answer) (/lifetime host))
(bb-key bbk-hail (/scope public) (/shape map) (/fields caller state line) (/lifetime host))
(bb-key bbk-reply-state (/scope private) (/shape map) (/fields state blocked-on) (/lifetime sleep))
