; ----------------------------------------------------------------------------
; conversation-roster-leave (think). A party of my talk whose public (conversing ..) no longer
; names it has left: his part in it ends in my mind. His leave-taking, heard, is what re-tests the
; board. Rejoining begins a new part (conversation-roster-join).
; ----------------------------------------------------------------------------

(think conversation-roster-leave
  (role ?talk {?talk participant @self} {?talk venue ?}
    (role ?party {?talk participant ?party}
                 {?party SAY ? ? /past}
                 (neq ?party @self)
                 (not (in-conversation ?party ?talk))
      (effects (end-belief {?talk participant ?party})))))
