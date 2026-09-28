; ----------------------------------------------------------------------------
; The INWARD grievance outlets - the two responses that are not acts against the
; grievance's focus, so they are not proposals: they resolve where they fire.
;
; suicide: the witnessed ideation is minted in a confidant's mind ALWAYS (the
;   testimony trail an investigator can find), the act itself only past the despair
;   + withdrawal gate. Disgrace and grief are different roads to it, so they are two
;   rules with their own weights - and the grief road's focus is the person who was
;   lost, who is typically dead, so it must not filter on a living target.
; strive: benign envy. Getting better at the contested domain is not a bespoke act -
;   competence accrues from performing that domain's real acts - so the response just
;   bleeds the rivalry off.
;
; No disposition tilt steers either: they are what is left when the outward outlets
; do not fit, and the despair gate is what decides the suicide, not a trait product.
; ----------------------------------------------------------------------------





(npc-think suicide_disgrace
  (cooldown 1 m try-once)
  (rng-stream deliberation)
  (role @self {@self pressure [k humiliation] ?target}:?pressure
    (when (chance (* (k-grievance-rate)
                     (* 0.01 (grievance-drive ?pressure ?target 1.0)))))
    (utility survival)
    (effects (resolve-suicide @self))))

(npc-think suicide_grief
  (cooldown 1 m try-once)
  (rng-stream deliberation)
  (role @self {@self pressure [k attachment-loss] ?target}:?pressure
    (when (chance (* (k-grievance-rate)
                     (* 0.03 (grievance-drive ?pressure ?target 1.0)))))
    (utility survival)
    (effects (resolve-suicide @self))))

(npc-think strive_rivalry
  (cooldown 1 m try-once)
  (rng-stream deliberation)
  (role @self {@self pressure [k rivalry-pressure] ?target}:?pressure
    (when (chance (* (k-grievance-rate)
                     (* 0.6 (grievance-drive ?pressure ?target 1.0)))))
    (effects (discharge-pressure ?pressure 0.5))))
