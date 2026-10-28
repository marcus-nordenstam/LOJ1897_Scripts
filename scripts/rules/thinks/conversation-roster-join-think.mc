; ----------------------------------------------------------------------------
; conversation-roster-join (think). Who is in my talk is what its board says (parties-of): a
; party there who is not yet a participant of it in my mind takes part in it from now - in my own
; mind, as every party does for himself (funcs/conversation.mc). A party joining the set wakes
; every party reading it.
; ----------------------------------------------------------------------------

(think conversation-roster-join
  (role ?talk {?talk participant @self} {?talk venue ?}
    (when (roster-lacks ?talk))
    (effects (roster-add ?talk))))
