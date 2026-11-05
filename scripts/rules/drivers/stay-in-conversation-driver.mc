; ----------------------------------------------------------------------------
; stay-in-conversation (drivers) - @self is in a conversation while he holds his part in it,
; {?talk participant @self}: hail or take-up begins it and leaving ends it (leave-conversation,
; funcs/conversation.mc). What he says in it keys off that part, and so does every way he leaves:
;   - stay          : while anyone else is in it his body stays with them
;                     (tasks/maintain-social-presence-task.mc), at what the talk is worth to him
;                     (conversation-utility).
;   - said-all      : once nobody has anything left to say and something has been said to him in
;                     it, he takes his leave; the last to run out goes, and his goodbye wakes the rest.
;   - excuse        : anything keener calling his body away, he takes his leave first, saying what
;                     calls him.
;   - crowded       : a crowded man leaves a talk he is held in only by his own want of it.
; Walked out of call he goes without a word (thinks/conversation-out-of-call-think.mc); left alone
; he simply goes (thinks/conversation-alone-think.mc).
; ----------------------------------------------------------------------------

(driver stay-in-conversation-driver
  (role ?talk {?talk participant @self} {?talk participant !@self}
    (when (in-conversation @self ?talk))
    (bind (conversation-utility ?talk) ?utility)
    (declare-utility (utility-band ?utility) (utility-value ?utility))
    (effects (maintain-proposal {@self maintain-social-presence ?talk}))))

(driver said-all-leave-driver
  (role ?talk {?talk participant @self}:?part (in-conversation @self ?talk) (other-party-in ?talk) (said-all ?talk)
    (role ?speaker {?talk participant ?speaker}
                   {?speaker SAY ? @self /past /most_recent}:?said
      (when (happened-since ?said ?part))
      (bind (conversation-utility ?talk) ?utility)
      (declare-utility (utility-band ?utility) (utility-value ?utility))
      (effects (maintain-proposal {@self take-leave ?talk} /uninterruptable /caused_by ?part)))))

; The decision is made once, and the leave it begins always completes. A take-leave only proposed
; may be what is being outbid, so only one under way holds it back.
(driver excuse-leave-driver
  (role ?talk {?talk participant @self}:?part
    (bind (top-competing-act {@self maintain-social-presence ?talk} (conversation-utility ?talk)) ?called-by)
    (when (and (in-conversation @self ?talk)
               (other-party-in ?talk)
               (substantial ?called-by)
               (unsubstantial (any {@self take-leave ?talk ?}))
               (not (proposed {@self take-leave ? (formulaic ? leave_taking excuse ?)}))))
    (declare-utility unbeatable)
    (lock)
    (lint-waive begin-proposal)
    (effects
      (begin-proposal {@self take-leave ?talk (formulaic [] leave_taking excuse ?called-by)} /uninterruptable
                      /caused_by ?part))))

(driver crowded-leave-driver
  (role @self {@self company [k crowded]}
    (role ?talk {?talk participant @self}:?part
      (when (and (in-conversation @self ?talk)
                 (other-party-in ?talk)
                 (< (conversation-utility ?talk) (utility errand 0.0))))
      (bind (conversation-utility ?talk) ?utility)
      (declare-utility (utility-band ?utility) (utility-value ?utility))
      (effects (maintain-proposal {@self take-leave ?talk} /caused_by ?part)))))
