; ----------------------------------------------------------------------------
; stay-in-talk (drivers) - @self is in a talk while he holds his part in it,
; {?talk participant @self}: hail or take-up begins it and leaving ends it (leave-talk,
; funcs/talk.mc). What he says in it keys off that part. While anyone else is in it his body
; stays with them (tasks/maintain-social-presence-task.mc) for every reason he has to, each its own
; bid on it:
;   - stay-want    : the talk itself, a want, while something is left to say in it (talked-out)
;                    and he has not had his fill of company;
;   - stay-obliged : each participant whose hail obliges him (obligation-hail), at what taking that
;                    participant's hail up is worth (hail-utility) - the keenest of them counts.
; With no reason left his presence is withdrawn, and outbid by something keener it gives way: its
; closing says his goodbye, or what draws him away. Walked out of shouting distance he goes without a word
; (thinks/talk-out-of-shouting-distance-think.mc); left alone he simply goes
; (thinks/talk-alone-think.mc).
; ----------------------------------------------------------------------------

(driver stay-want-driver
  (role ?talk {?talk participant @self}:?part
    (when (and (in-talk @self ?talk)
               (other-participant-in ?talk)
               (not (talked-out ?talk ?part))
               (unsubstantial (any {@self company [k crowded]}))))
    (bind (utility want (k-talk-want-value)) ?utility)
    (declare-utility (utility-band ?utility) (utility-value ?utility))
    (effects (maintain-proposal {@self maintain-social-presence ?talk}))))

(driver stay-obliged-driver
  (role ?talk {?talk participant @self}
    (role ?participant (bb-public-members ?talk bbk-roster)
                 (neq ?participant @self)
                 (obligation-hail ?participant)
      (when (in-talk @self ?talk))
      (bind (hail-utility ?participant) ?utility)
      (declare-utility (utility-band ?utility) (utility-value ?utility))
      (effects (maintain-proposal {@self maintain-social-presence ?talk})))))
