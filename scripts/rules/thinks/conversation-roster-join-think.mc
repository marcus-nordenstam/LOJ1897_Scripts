; ----------------------------------------------------------------------------
; conversation-roster-join (think). Who is in my talk: a man I have heard speak whose public
; (conversing ..) names the conversation I am in takes part in it, so I know him a participant
; from now - in my own mind, as every party does for himself (funcs/conversation.mc). Hearing him
; is what re-tests the board: a joiner always speaks, answering the hail or hailing himself.
; ----------------------------------------------------------------------------

(think conversation-roster-join
  (role ?talk {?talk participant @self} {?talk venue ?}
    (role ?party {?party SAY ? ? /past}
                 -{?talk participant ?party}
                 (neq ?party @self)
                 (in-conversation ?party ?talk)
      (effects (begin-belief {?talk participant ?party})))))
