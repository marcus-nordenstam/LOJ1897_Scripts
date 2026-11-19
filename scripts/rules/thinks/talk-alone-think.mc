; ----------------------------------------------------------------------------
; talk-alone (think). Left alone in a talk, @self leaves it, which releases it. A
; talk with nobody else in it is over, so leaving it waits on no act of his winning his body.
; ----------------------------------------------------------------------------

(think talk-alone
  (role ?talk {?talk participant @self} {?talk venue ?}
    (when (not (other-participant-in ?talk)))
    (effects (leave-talk ?talk))))
