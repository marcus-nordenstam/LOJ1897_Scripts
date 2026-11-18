; ----------------------------------------------------------------------------
; The talk's boards (funcs/talk.mc). bbk-line, on a talk's public board, is its LOG: one record per
; line said in it, keyed by the line (the abs SAY), its reply-to the line it replies to, @nothing for
; none, in the order said. bbk-called, on a hailer's own board, names the talk whose board his hail
; put a man on, keyed by that man, until the hail is over. bbk-hail-answer, on a hailer's own public
; board, is what each man he hailed answered, keyed by that man: taken or turned-down, cleared when
; he hails him again. bbk-reply-state, on a
; man's own object of a talk, is what he makes of each line said to him there that is owed a reply
; or waits on what its speaker meant, keyed by the line in the order heard: its state - owed (heard,
; a reply owed once nothing blocks it), unowed (it only waits to be understood), due (he is obliged
; to reply now), given - and blocked-on, the then, there, he, she or it its talk gives no meaning, or
; the man he must first ask which one he is. bbk-reply-to, on a man's own board, is the line each
; thing he is about to say replies to, keyed by the message, noted by the rule that wants it said
; and read when the line is logged as its SAY begins.
; ----------------------------------------------------------------------------

(bb-key bbk-line (/scope public) (/shape sequence) (/fields reply-to) (/bound 32) (/lifetime host))
(bb-key bbk-called (/scope private) (/shape map) (/fields talk) (/lifetime sleep))
(bb-key bbk-hail-answer (/scope public) (/shape map) (/fields answer) (/lifetime host))
(bb-key bbk-reply-state (/scope private) (/shape map) (/fields state blocked-on) (/lifetime sleep))
(bb-key bbk-reply-to (/scope private) (/shape map) (/fields line) (/lifetime sleep))
