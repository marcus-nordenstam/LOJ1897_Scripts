; ----------------------------------------------------------------------------
; conversation-said-all (think). @self has nothing left to say in his conversation: he withdraws
; his has-more mark from it.
; ----------------------------------------------------------------------------

(think conversation-said-all
  (role ?talk {?talk participant @self} {?talk venue ?}
    (when (and (not (agenda-for ?talk)) (not (bb-public-none @self has-more ?talk))))
    (effects (bb-public-clear @self has-more))))
