; ----------------------------------------------------------------------------
; The LAWFUL grievance outlets - confessing and reporting. Same shape as the
; unlawful file: one rule per way of spending a standing pressure, a role binding
; the grievance as the durable reason, a running-act latch on the gate, and a
; maintain-proposal that withdraws itself when the reason goes.
;
; These roll against (k-grievance-rate) rather than (crime-scale): switching crime
; off must not also switch off the town's lawful answers to a grievance.
;
; The prosocial disposition tilt is the inverse of the aggressive one - the polite
; and compassionate confess and report where the dark and volatile expose and coerce.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.mc")

; ---- report-crime ----------------------------------------------------------
; Take it to the police. Indignation and want are different motives for the same
; walk to the station, so they are two rules with their own weights.
(npc-think report_injustice
  (cooldown 1 m)
  (rng-stream deliberation)
  (role ?target (any_human ?target)
    {@self pressure [k injustice] ?target}:?pressure)
  (when (or {@self report-crime ?target}
            (chance (* (k-grievance-rate)
                       (* 0.5 (grievance-drive ?pressure ?target (pro-tilt)))))))
  (utility want (* (disinhibition) 1000))
  (effects (maintain-proposal {@self report-crime ?target /caused_by ?pressure})))

(npc-think report_for_relief
  (cooldown 1 m)
  (rng-stream deliberation)
  (role ?target (any_human ?target)
    {@self pressure [k resource-scarcity] ?target}:?pressure)
  (when (or {@self report-crime ?target}
            (chance (* (k-grievance-rate)
                       (* 0.3 (grievance-drive ?pressure ?target (pro-tilt)))))))
  (utility want (* (disinhibition) 1000))
  (effects (maintain-proposal {@self report-crime ?target /caused_by ?pressure})))

; ---- confess-letter --------------------------------------------------------
; Put it in writing. Confessing because the secret is about to break and confessing
; because you cannot carry it are different acts - one is calculated, one is remorse.
(npc-think confess_at_risk
  (cooldown 1 m)
  (rng-stream deliberation)
  (role ?target (any_human ?target)
    {@self pressure [k exposure-risk] ?target}:?pressure)
  (when (or {@self confess-letter ?target}
            (chance (* (k-grievance-rate)
                       (* 0.2 (grievance-drive ?pressure ?target (pro-tilt)))))))
  (utility want (* (disinhibition) 1000))
  (effects (maintain-proposal {@self confess-letter ?target /caused_by ?pressure})))

(npc-think confess_remorse
  (cooldown 1 m)
  (rng-stream deliberation)
  (role ?target (any_human ?target)
    {@self pressure [k moral-violation] ?target}:?pressure)
  (when (or {@self confess-letter ?target}
            (chance (* (k-grievance-rate)
                       (* 0.5 (grievance-drive ?pressure ?target (pro-tilt)))))))
  (utility want (* (disinhibition) 1000))
  (effects (maintain-proposal {@self confess-letter ?target /caused_by ?pressure})))
