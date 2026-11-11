; ----------------------------------------------------------------------------
; conversation-has-more (think). While @self still has something to say in his conversation
; (agenda-for, funcs/conversation.mc) he shows it - he is in the conversation's has-more set - and
; once he has nothing left he comes off it.
; ----------------------------------------------------------------------------

(think conversation-has-more
  (lod presented)
  (role ?talk {?talk participant @self} {?talk venue ?}
    (bind (tolerate (agenda-for ?talk)) ?more)
    (when (neq ?more (substantial (bb-public-any ?talk has-more @self))))
    (effects
      (if ?more
          (then (bb-public-add-member ?talk has-more @self))
          (else (bb-public-remove-member ?talk has-more @self))))))
