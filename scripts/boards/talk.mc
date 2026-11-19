; ----------------------------------------------------------------------------
; The talk's boards (funcs/talk.mc). bbk-roster, on a talk's public board, is who is on it, keyed
; by the man: his standing is hailed while a hail has put him there and he holds no part in the talk,
; in once he holds one. bbk-line, on a talk's public board, is its LOG: one record per
; line said in it, keyed by the line (the abs SAY), in the order said; the line it replies to rides
; on its message (the reply-to rider). The man a line was said to writes on its record what he
; makes of it, and nobody else reads that: reply, owed from the moment he hears a line whose kind
; asks for one until he has replied, and waits-on, the then, there, he, she or it its talk has not
; said yet, or ghost for a man he must first ask which one he is. A record with either set is live: it is
; never the one dropped when the log is full. bbk-hail, on a talk's public board, is a hail made in that talk, keyed by the man
; hailed: its hailer, the opening he hailed with, and its state - hailed from the instant the hailer's
; opening is said, taken or turned-down once the man hailed has answered - until the hailer's hail is
; over and he clears it. bbk-turned-down, on a hailer's own board, is his memory of a man who turned
; his hail down, keyed by that man: when it happened. He does not hail that man again while it is
; fresh (turned-down-by), and it goes when he takes up a hail of that man's own.
; ----------------------------------------------------------------------------

(bb-key bbk-roster (/scope public) (/shape map) (/fields standing) (/lifetime host))
(bb-key bbk-line (/scope public) (/shape sequence) (/fields reply waits-on) (/live reply waits-on) (/bound 32)
        (/lifetime host))
(bb-key bbk-turned-down (/scope private) (/shape map) (/fields at) (/lifetime host))
(bb-key bbk-hail (/scope public) (/shape map) (/fields hailer state line) (/lifetime host))
