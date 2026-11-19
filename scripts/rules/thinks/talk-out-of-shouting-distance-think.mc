; ----------------------------------------------------------------------------
; talk-out-of-shouting-distance (think). Walked out of shouting distance of everyone else he knows to be in his
; talk, @self has left it, and goes without a word.
; ----------------------------------------------------------------------------

(think talk-out-of-shouting-distance
  (role ?talk {?talk participant @self} {?talk venue ?}
    (when (and (other-participant-in ?talk) (out-of-shouting-distance ?talk)))
    (effects (leave-talk ?talk))))
