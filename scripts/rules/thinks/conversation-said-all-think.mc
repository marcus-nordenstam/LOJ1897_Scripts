; ----------------------------------------------------------------------------
; conversation-said-all (think). @self has nothing left to say in his conversation: he comes off
; its has-more set.
; ----------------------------------------------------------------------------

(think conversation-said-all
  (role ?talk {?talk participant @self} {?talk venue ?}
    (when (and (not (agenda-for ?talk)) (substantial (bb-public-any ?talk has-more @self))))
    (effects (bb-public-remove-member ?talk has-more @self))))
