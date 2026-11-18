; ----------------------------------------------------------------------------
; talk-out-of-call (think). Walked out of call of everyone else he knows to be in his
; talk, @self has left it, and goes without a word.
; ----------------------------------------------------------------------------

(think talk-out-of-call
  (role ?talk {?talk participant @self} {?talk venue ?}
    (when (and (other-party-in ?talk) (out-of-call-of ?talk)))
    (effects (leave-talk ?talk))))
