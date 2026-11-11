; ----------------------------------------------------------------------------
; conversation-out-of-call (think). Walked out of call of everyone else he knows to be in his
; conversation, @self has left it, and goes without a word.
; ----------------------------------------------------------------------------

(think conversation-out-of-call
  (lod presented)
  (role ?talk {?talk participant @self} {?talk participant !@self} {?talk venue ?}
    (when (out-of-call-of ?talk))
    (effects (leave-conversation ?talk))))
