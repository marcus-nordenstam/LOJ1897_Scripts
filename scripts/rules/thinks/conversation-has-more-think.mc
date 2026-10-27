; ----------------------------------------------------------------------------
; conversation-has-more (think). While @self still has something to say in his conversation
; (agenda-for, funcs/conversation.mc) he shows it: his board's has-more names the conversation,
; which the conversation's own board records among those who still have something to say.
; ----------------------------------------------------------------------------

(think conversation-has-more
  (role ?talk {?talk participant @self} {?talk venue ?}
    (when (and (agenda-for ?talk) (bb-public-none @self has-more ?talk)))
    (effects (bb-public-write @self has-more ?talk))))
