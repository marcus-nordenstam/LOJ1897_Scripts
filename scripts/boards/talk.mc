; ----------------------------------------------------------------------------
; The talk's boards (funcs/talk.mc). bbk-roster, on a talk's public board, is who is on it, keyed
; by the man: his standing is hailed while a hail has put him there and he holds no part in the talk,
; in once he holds one. bbk-line, on a talk's public board, is its LOG: one record per
; line said in it, keyed by the line (the abs SAY), in the order said; the line it replies to rides
; on its message (the reply-to rider). bbk-hail, on a talk's public board, is a hail made in that talk, keyed by the man
; hailed: its hailer, the opening he hailed with, and its state - hailed from the instant the hailer's
; opening is said, taken or turned-down once the man hailed has answered - until the hailer's hail is
; over and he clears it. bbk-turned-down, on a hailer's own board, is his memory of a man who turned
; his hail down, keyed by that man: when it happened. He does not hail that man again while it is
; fresh (turned-down-by), and it goes when he takes up a hail of that man's own.
; bbk-reply-state, on a
; man's own object of a talk, is what he makes of each line said to him there that is owed a reply
; or waits on what its speaker meant, keyed by the line in the order heard: its state - owed (heard,
; a reply owed once nothing blocks it), unowed (it only waits to be understood), due (he is obliged
; to reply now), given - and blocked-on, the then, there, he, she or it its talk gives no meaning, or
; the man he must first ask which one he is.
; ----------------------------------------------------------------------------

(bb-key bbk-roster (/scope public) (/shape map) (/fields standing) (/lifetime host))
(bb-key bbk-line (/scope public) (/shape sequence) (/bound 32) (/lifetime host))
(bb-key bbk-turned-down (/scope private) (/shape map) (/fields at) (/lifetime host))
(bb-key bbk-hail (/scope public) (/shape map) (/fields hailer state line) (/lifetime host))
(bb-key bbk-reply-state (/scope private) (/shape map) (/fields state blocked-on) (/lifetime sleep))
