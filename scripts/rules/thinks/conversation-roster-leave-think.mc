; ----------------------------------------------------------------------------
; conversation-roster-leave (think). A participant of a talk its participant set no longer holds
; has left: his part in it ends in my mind, whether I am still in it or not, so nobody I knew in a
; talk stays in it in my mind after he has gone. Rejoining begins a new part
; (conversation-roster-join).
; ----------------------------------------------------------------------------

(think conversation-roster-leave
  (role ?talk [k conversation] {?talk participant ?}
    (role ?party {?talk participant ?party}
                 (neq ?party @self)
      (when (not (in-conversation ?party ?talk)))
      (effects (end-belief {?talk participant ?party})))))
