; ----------------------------------------------------------------------------
; talk-roster-join (think). Who is in my talk is what its board says (talk-participants): a
; participant there who is not yet a participant of it in my mind takes part in it from now - in my own
; mind, as every participant does for himself (funcs/talk.mc). A participant joining the set wakes
; every participant reading it.
; ----------------------------------------------------------------------------

(think talk-roster-join
  (role ?talk {?talk participant @self} {?talk venue ?}
    (when (roster-lacks ?talk))
    (effects (roster-add ?talk))))
