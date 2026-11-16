; ----------------------------------------------------------------------------
; The talk's boards (funcs/talk.mc). bbk-line, on a talk's public board, is its LOG: one record per
; line said in it, keyed by the line (the abs SAY), its reply-to the line it replies to, @nothing for
; none, in the order said. bbk-opened, on a man's own public board, names the talk he opened to say
; a line to a man he shared none with, keyed by that man, while he holds it open: the man answering
; finds it there. bbk-hail-answer, on a hailer's own public board, is what each man he hailed answered,
; keyed by that man: taken or turned-down, cleared when he hails him again.
; ----------------------------------------------------------------------------

(bb-key bbk-line (/scope public) (/shape sequence) (/fields reply-to) (/bound 32) (/lifetime host))
(bb-key bbk-opened (/scope public) (/shape map) (/fields talk) (/lifetime host))
(bb-key bbk-hail-answer (/scope public) (/shape map) (/fields answer) (/lifetime host))
