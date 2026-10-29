; ----------------------------------------------------------------------------
; The LAWFUL grievance outlets - confessing and reporting. Same shape as the
; unlawful file: one rule per way of spending a standing pressure, a role binding
; the grievance as the durable reason, a running-act latch on the gate, a
; maintain-proposal that withdraws itself when the reason goes; the act, concluding /succ,
; spends the grievance that caused it (spend-grievance), as an unlawful outlet's intent does.
;
; These roll against (k-grievance-rate) rather than (crime-scale): switching crime
; off must not also switch off the town's lawful answers to a grievance.
;
; The prosocial disposition tilt is the inverse of the aggressive one - the polite
; and compassionate confess and report where the dark and volatile expose and coerce.
; ----------------------------------------------------------------------------


; ---- report-crime ----------------------------------------------------------
; Take it to the police. Indignation and want are different motives for the same
; walk to the station, so they are two rules with their own weights.
(driver report-injustice-driver
  (cooldown 1 m try-once)
  (rng-stream deliberation)
  (role @self {@self inhibition ?inhibition}
              {@self prosocial-tilt ?prosocial-tilt}
    (role ?target {?target isa [k human], condition [k alive]}
      {@self pressure [k injustice] ?target}:?pressure
      -{@self report-crime ?target /succ /caused_by ?pressure}
      (when (or {@self report-crime ?target}
                (chance (* (k-grievance-rate)
                           (* 0.5 (grievance-drive ?pressure ?target ?prosocial-tilt))))))
      (declare-utility want (* (- 1.0 ?inhibition) 1000.0))
      (effects (maintain-proposal {@self report-crime ?target /caused_by ?pressure})))))

(driver report-for-relief-driver
  (cooldown 1 m try-once)
  (rng-stream deliberation)
  (role @self {@self inhibition ?inhibition}
              {@self prosocial-tilt ?prosocial-tilt}
    (role ?target {?target isa [k human], condition [k alive]}
      {@self pressure [k resource-scarcity] ?target}:?pressure
      -{@self report-crime ?target /succ /caused_by ?pressure}
      (when (or {@self report-crime ?target}
                (chance (* (k-grievance-rate)
                           (* 0.3 (grievance-drive ?pressure ?target ?prosocial-tilt))))))
      (declare-utility want (* (- 1.0 ?inhibition) 1000.0))
      (effects (maintain-proposal {@self report-crime ?target /caused_by ?pressure})))))

; ---- confess-letter --------------------------------------------------------
; Put it in writing. Confessing because the secret is about to break and confessing
; because you cannot carry it are different acts - one is calculated, one is remorse.
(driver confess-at-risk-driver
  (cooldown 1 m try-once)
  (rng-stream deliberation)
  (role @self {@self inhibition ?inhibition}
              {@self prosocial-tilt ?prosocial-tilt}
    (role ?target {?target isa [k human], condition [k alive]}
      {@self pressure [k exposure-risk] ?target}:?pressure
      -{@self confess-letter ?target /succ /caused_by ?pressure}
      (when (or {@self confess-letter ?target}
                (chance (* (k-grievance-rate)
                           (* 0.2 (grievance-drive ?pressure ?target ?prosocial-tilt))))))
      (declare-utility want (* (- 1.0 ?inhibition) 1000.0))
      (effects (maintain-proposal {@self confess-letter ?target /caused_by ?pressure})))))

(driver confess-remorse-driver
  (cooldown 1 m try-once)
  (rng-stream deliberation)
  (role @self {@self inhibition ?inhibition}
              {@self prosocial-tilt ?prosocial-tilt}
    (role ?target {?target isa [k human], condition [k alive]}
      {@self pressure [k moral-violation] ?target}:?pressure
      -{@self confess-letter ?target /succ /caused_by ?pressure}
      (when (or {@self confess-letter ?target}
                (chance (* (k-grievance-rate)
                           (* 0.5 (grievance-drive ?pressure ?target ?prosocial-tilt))))))
      (declare-utility want (* (- 1.0 ?inhibition) 1000.0))
      (effects (maintain-proposal {@self confess-letter ?target /caused_by ?pressure})))))
