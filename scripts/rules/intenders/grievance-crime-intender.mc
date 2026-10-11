; ----------------------------------------------------------------------------
; The UNLAWFUL grievance outlets - one rule per way of spending a standing
; {@self pressure <kind> /aux <focus>} belief on a crime against its focus.
;
; Each rule is an INTENDER: a role binds the grievance itself (the durable REASON, read never
; re-minted), a latched (chance ...) tip resolves on the crime, and the intent it mints - caused
; by the grievance - stands while the grievance does. pursue-<act> (drivers/grievance-crime-driver.mc)
; carries it out, and the act concluding /succ ends the intent, which RELEASES the grievance:
; acting on a grievance is what spends it.
;
; Release is gradual (0.75 of the remaining salience per spent intent) rather than one-shot:
; the pressure floors, pressure-intensity reads ~0, decay forgets the belief and the role
; stops binding.
;
; The preconditions each outlet needs are ROLE FILTERS / gate conjuncts here, not
; multiply-by-zero factors in a scorer: an other-directed aggression never aims at
; @self, and an expose needs discreditable material about its focus to expose.
;
; Everything unlawful multiplies by (crime-scale), so setting it to 0 shuts this
; whole file off cleanly - the same switch the old deliberate rule carried.
; ----------------------------------------------------------------------------


; ---- expose ----------------------------------------------------------------
; Make the focus's discreditable material public. Two grievances drive it and they
; are different acts: answering a slight against yourself, and answering a wrong.
(intender expose-slight
  (cooldown 1 m try-once)
  (rng-stream deliberation)
  (role @self {@self inhibition ?inhibition}
              {@self aggressive-tilt ?aggressive-tilt}
    (role ?target {?target isa [k human], condition [k alive]}
      {@self pressure [k humiliation|status-loss|rivalry-pressure] ?target}:?pressure
      (when (and (not (= ?target @self))
                     {?target lover|HAVE-SEX-WITH ? /ever}
                     (latch-eval
                         (chance (* (crime-scale)
                                    (* 0.4 (grievance-drive ?pressure ?target ?aggressive-tilt)))))))
      (declare-utility want (* (- 1.0 ?inhibition) 1000.0))
      (effects (maintain-intent {@self intent {@self expose ?target}} /caused_by ?pressure)))))

(intender expose-wrongdoing
  (cooldown 1 m try-once)
  (rng-stream deliberation)
  (role @self {@self inhibition ?inhibition}
              {@self aggressive-tilt ?aggressive-tilt}
    (role ?target {?target isa [k human], condition [k alive]}
      {@self pressure [k injustice] ?target}:?pressure
      (when (and (not (= ?target @self))
                     {?target lover|HAVE-SEX-WITH ? /ever}
                     (latch-eval
                         (chance (* (crime-scale)
                                    (* 0.5 (grievance-drive ?pressure ?target ?aggressive-tilt)))))))
      (declare-utility want (* (- 1.0 ?inhibition) 1000.0))
      (effects (maintain-intent {@self intent {@self expose ?target}} /caused_by ?pressure)))))

; ---- humiliate -------------------------------------------------------------
; Put the focus down in public - the status answer to a status injury.
(intender humiliate-slight
  (cooldown 1 m try-once)
  (rng-stream deliberation)
  (role @self {@self inhibition ?inhibition}
              {@self aggressive-tilt ?aggressive-tilt}
    (role ?target {?target isa [k human], condition [k alive]}
      {@self pressure [k humiliation|rivalry-pressure] ?target}:?pressure
      (when (and (not (= ?target @self))
                     (latch-eval
                         (chance (* (crime-scale)
                                    (* 0.5 (grievance-drive ?pressure ?target ?aggressive-tilt)))))))
      (declare-utility want (* (- 1.0 ?inhibition) 1000.0))
      (effects (maintain-intent {@self intent {@self humiliate ?target}} /caused_by ?pressure)))))

; ---- coerce ----------------------------------------------------------------
; Press a threat on the focus. Silencing the source of a slight and holding on to
; someone you are losing are the same act for opposite reasons, so they are two rules.
(intender coerce-silence
  (cooldown 1 m try-once)
  (rng-stream deliberation)
  (role @self {@self inhibition ?inhibition}
              {@self aggressive-tilt ?aggressive-tilt}
    (role ?target {?target isa [k human], condition [k alive]}
      {@self pressure [k humiliation] ?target}:?pressure
      (when (and (not (= ?target @self))
                     (latch-eval
                         (chance (* (crime-scale)
                                    (* 0.10 (grievance-drive ?pressure ?target ?aggressive-tilt)))))))
      (declare-utility want (* (- 1.0 ?inhibition) 1000.0))
      (effects (maintain-intent {@self intent {@self coerce ?target}} /caused_by ?pressure)))))

(intender coerce-hold
  (cooldown 1 m try-once)
  (rng-stream deliberation)
  (role @self {@self inhibition ?inhibition}
              {@self aggressive-tilt ?aggressive-tilt}
    (role ?target {?target isa [k human], condition [k alive]}
      {@self pressure [k attachment-loss] ?target}:?pressure
      (when (and (not (= ?target @self))
                     (latch-eval
                         (chance (* (crime-scale)
                                    (* 0.20 (grievance-drive ?pressure ?target ?aggressive-tilt)))))))
      (declare-utility want (* (- 1.0 ?inhibition) 1000.0))
      (effects (maintain-intent {@self intent {@self coerce ?target}} /caused_by ?pressure)))))

; ---- seduce ----------------------------------------------------------------
; Replace what was lost by taking someone else's attachment.
(intender seduce-replacement
  (cooldown 1 m try-once)
  (rng-stream deliberation)
  (role @self {@self inhibition ?inhibition}
              {@self aggressive-tilt ?aggressive-tilt}
    (role ?target {?target isa [k human], condition [k alive]}
      {@self pressure [k attachment-loss] ?target}:?pressure
      (when (and (not (= ?target @self))
                     (latch-eval
                         (chance (* (crime-scale)
                                    (* 0.2 (grievance-drive ?pressure ?target ?aggressive-tilt)))))))
      (declare-utility want (* (- 1.0 ?inhibition) 1000.0))
      (effects (maintain-intent {@self intent {@self seduce ?target}} /caused_by ?pressure)))))

; ---- bribe -----------------------------------------------------------------
; Buy the focus's silence. A crime, but not an aggression - no disposition tilt
; steers it, so the drive is the grievance's heat alone.
(intender bribe-to-bury
  (cooldown 1 m try-once)
  (rng-stream deliberation)
  (role @self {@self inhibition ?inhibition}
    (role ?target {?target isa [k human], condition [k alive]}
      {@self pressure [k exposure-risk] ?target}:?pressure
      (when (and (not (= ?target @self))
                     (latch-eval
                         (chance (* (crime-scale)
                                    (* 0.4 (grievance-drive ?pressure ?target 1.0)))))))
      (declare-utility want (* (- 1.0 ?inhibition) 1000.0))
      (effects (maintain-intent {@self intent {@self bribe ?target}} /caused_by ?pressure)))))
