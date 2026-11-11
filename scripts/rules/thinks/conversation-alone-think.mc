; ----------------------------------------------------------------------------
; conversation-alone (think). Left alone in a conversation, @self leaves it, which releases it. A
; talk with nobody else in it is over, so leaving it waits on no act of his winning his body.
; ----------------------------------------------------------------------------

(think conversation-alone
  (lod presented)
  (role ?talk {?talk participant @self} {?talk venue ?}
    (when (not (other-party-in ?talk)))
    (effects (leave-conversation ?talk))))
