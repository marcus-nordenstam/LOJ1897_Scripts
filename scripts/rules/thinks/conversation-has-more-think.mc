; ----------------------------------------------------------------------------
; conversation-has-more (think). While @self still has something to say in his conversation
; (agenda-for, funcs/conversation.mc) he shows it: he is in the conversation's has-more set.
; ----------------------------------------------------------------------------

(think conversation-has-more
  (role ?talk {?talk participant @self} {?talk venue ?}
    (when (and (agenda-for ?talk) (unsubstantial (bb-public-any ?talk has-more @self))))
    (effects (bb-public-add-member ?talk has-more @self))))
