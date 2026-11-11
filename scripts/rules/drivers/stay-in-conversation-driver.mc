; ----------------------------------------------------------------------------
; stay-in-conversation (drivers) - @self is in a conversation while he holds his part in it,
; {?talk participant @self}: hail or take-up begins it and leaving ends it (leave-conversation,
; funcs/conversation.mc). What he says in it keys off that part. While anyone else is in it his body
; stays with them (tasks/maintain-social-presence-task.mc) for every reason he has to, each its own
; bid on it:
;   - stay-want    : the talk itself, a want, while something is left to say in it (talked-out)
;                    and he has not had his fill of company;
;   - stay-obliged : each party whose hail obliges him (obligation-hail), at what taking that
;                    party's hail up is worth (hail-utility) - the keenest of them counts.
; With no reason left his presence is withdrawn, and outbid by something keener it gives way: its
; closing says his goodbye, or what calls him away. Walked out of call he goes without a word
; (thinks/conversation-out-of-call-think.mc); left alone he simply goes
; (thinks/conversation-alone-think.mc).
; ----------------------------------------------------------------------------

(driver stay-want-driver
  (lod presented)
  (role ?talk {?talk participant @self}:?part {?talk participant !@self}
    (when (and (in-conversation @self ?talk)
               (not (talked-out ?talk ?part))
               (unsubstantial (any {@self company [k crowded]}))))
    (bind (utility want (k-conversation-want-value)) ?utility)
    (declare-utility (utility-band ?utility) (utility-value ?utility))
    (effects (maintain-proposal {@self maintain-social-presence ?talk}))))

(driver stay-obliged-driver
  (lod presented)
  (role ?talk {?talk participant @self} {?talk participant !@self}
    (role ?party {?talk participant ?party}
                 (neq ?party @self)
                 (obligation-hail ?party)
      (when (in-conversation @self ?talk))
      (bind (hail-utility ?party) ?utility)
      (declare-utility (utility-band ?utility) (utility-value ?utility))
      (effects (maintain-proposal {@self maintain-social-presence ?talk})))))
