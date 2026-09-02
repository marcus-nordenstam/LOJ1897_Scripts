; ----------------------------------------------------------------------------
; The UNLAWFUL grievance outlets - one rule per way of spending a standing
; {@self pressure <kind> /aux <focus>} belief on a crime against its focus.
;
; Each rule is a driver in the crime_of_passion / covet_inheritance mould: a role
; binds the grievance itself (the durable REASON, read never re-minted, so the drive
; fades the moment the grievance is spent), a (chance ...) tip opens the campaign,
; and the RUNNING act latches the gate so a live attempt is not re-rolled away.
; maintain-proposal means the proposal withdraws by itself the instant the reason
; goes - the crime task competes globally on the want tier and owns its own outcome.
;
; The preconditions each outlet needs are ROLE FILTERS here, not multiply-by-zero
; factors in a scorer: an other-directed aggression never aims at @self, and an
; expose needs discreditable material about its focus to expose.
;
; Everything unlawful multiplies by (crime-scale), so setting it to 0 shuts this
; whole file off cleanly - the same switch the old deliberate rule carried.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

; ---- expose ----------------------------------------------------------------
; Make the focus's discreditable material public. Two grievances drive it and they
; are different acts: answering a slight against yourself, and answering a wrong.
(npc-think expose_slight
  (cooldown 1 m)
  (rng-stream deliberation)
  (role ?target (any_human ?target)
    {@self pressure [k humiliation|status-loss|rivalry-pressure] ?target}:?pressure)
  (when (and (not (= ?target @self))
             -{?target condition [k dead]}
             (> (prob {?target lover|HAVE-SEX-WITH ? /ever}) 0)
             (or {@self expose ?target}
                 (chance (* (crime-scale)
                            (* 0.4 (grievance-drive ?pressure ?target (agg-tilt))))))))
  (utility want (* (disinhibition) 1000))
  (effects (maintain-proposal {@self expose ?target /caused_by ?pressure})))

(npc-think expose_wrongdoing
  (cooldown 1 m)
  (rng-stream deliberation)
  (role ?target (any_human ?target)
    {@self pressure [k injustice] ?target}:?pressure)
  (when (and (not (= ?target @self))
             -{?target condition [k dead]}
             (> (prob {?target lover|HAVE-SEX-WITH ? /ever}) 0)
             (or {@self expose ?target}
                 (chance (* (crime-scale)
                            (* 0.5 (grievance-drive ?pressure ?target (agg-tilt))))))))
  (utility want (* (disinhibition) 1000))
  (effects (maintain-proposal {@self expose ?target /caused_by ?pressure})))

; ---- humiliate -------------------------------------------------------------
; Put the focus down in public - the status answer to a status injury.
(npc-think humiliate_slight
  (cooldown 1 m)
  (rng-stream deliberation)
  (role ?target (any_human ?target)
    {@self pressure [k humiliation|rivalry-pressure] ?target}:?pressure)
  (when (and (not (= ?target @self))
             -{?target condition [k dead]}
             (or {@self humiliate ?target}
                 (chance (* (crime-scale)
                            (* 0.5 (grievance-drive ?pressure ?target (agg-tilt))))))))
  (utility want (* (disinhibition) 1000))
  (effects (maintain-proposal {@self humiliate ?target /caused_by ?pressure})))

; ---- coerce ----------------------------------------------------------------
; Press a threat on the focus. Silencing the source of a slight and holding on to
; someone you are losing are the same act for opposite reasons, so they are two rules.
(npc-think coerce_silence
  (cooldown 1 m)
  (rng-stream deliberation)
  (role ?target (any_human ?target)
    {@self pressure [k humiliation] ?target}:?pressure)
  (when (and (not (= ?target @self))
             -{?target condition [k dead]}
             (or {@self coerce ?target}
                 (chance (* (crime-scale)
                            (* 0.10 (grievance-drive ?pressure ?target (agg-tilt))))))))
  (utility want (* (disinhibition) 1000))
  (effects (maintain-proposal {@self coerce ?target /caused_by ?pressure})))

(npc-think coerce_hold
  (cooldown 1 m)
  (rng-stream deliberation)
  (role ?target (any_human ?target)
    {@self pressure [k attachment-loss] ?target}:?pressure)
  (when (and (not (= ?target @self))
             -{?target condition [k dead]}
             (or {@self coerce ?target}
                 (chance (* (crime-scale)
                            (* 0.20 (grievance-drive ?pressure ?target (agg-tilt))))))))
  (utility want (* (disinhibition) 1000))
  (effects (maintain-proposal {@self coerce ?target /caused_by ?pressure})))

; ---- seduce ----------------------------------------------------------------
; Replace what was lost by taking someone else's attachment.
(npc-think seduce_replacement
  (cooldown 1 m)
  (rng-stream deliberation)
  (role ?target (any_human ?target)
    {@self pressure [k attachment-loss] ?target}:?pressure)
  (when (and (not (= ?target @self))
             -{?target condition [k dead]}
             (or {@self seduce ?target}
                 (chance (* (crime-scale)
                            (* 0.2 (grievance-drive ?pressure ?target (agg-tilt))))))))
  (utility want (* (disinhibition) 1000))
  (effects (maintain-proposal {@self seduce ?target /caused_by ?pressure})))

; ---- frame -----------------------------------------------------------------
; Pin your own breach on someone else - the guilty actor's way out.
(npc-think frame_deflection
  (cooldown 1 m)
  (rng-stream deliberation)
  (role ?target (any_human ?target)
    {@self pressure [k moral-violation] ?target}:?pressure)
  (when (and (not (= ?target @self))
             -{?target condition [k dead]}
             (or {@self frame ?target}
                 (chance (* (crime-scale)
                            (* 0.2 (grievance-drive ?pressure ?target (agg-tilt))))))))
  (utility want (* (disinhibition) 1000))
  (effects (maintain-proposal {@self frame ?target /caused_by ?pressure})))

; ---- bribe -----------------------------------------------------------------
; Buy the focus's silence. A crime, but not an aggression - no disposition tilt
; steers it, so the drive is the grievance's heat alone.
(npc-think bribe_to_bury
  (cooldown 1 m)
  (rng-stream deliberation)
  (role ?target (any_human ?target)
    {@self pressure [k exposure-risk] ?target}:?pressure)
  (when (and (not (= ?target @self))
             -{?target condition [k dead]}
             (or {@self bribe ?target}
                 (chance (* (crime-scale)
                            (* 0.4 (grievance-drive ?pressure ?target 1)))))))
  (utility want (* (disinhibition) 1000))
  (effects (maintain-proposal {@self bribe ?target /caused_by ?pressure})))
