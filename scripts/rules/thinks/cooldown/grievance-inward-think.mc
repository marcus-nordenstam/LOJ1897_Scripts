; ----------------------------------------------------------------------------
; The INWARD grievance outlets - the two responses that are not acts against the
; grievance's focus, so they are not proposals: they resolve where they fire.
;
; suicide: an INTENT, decided on the pressure past the despair + withdrawal gate
;   (despairing), so it can be confided and known; pursue-DIE (thinks/hot/die-think.mc)
;   carries it out. Disgrace and grief are different roads to it, so they are two
;   intenders with their own weights - and the grief road's focus is the person who was
;   lost, who is typically dead, so it must not filter on a living target.
; strive: benign envy. Getting better at the contested domain is not a bespoke act -
;   competence accrues from performing that domain's real acts - so the response just
;   bleeds the rivalry off.
;
; No disposition tilt steers either: they are what is left when the outward outlets
; do not fit, and the despair gate is what decides the suicide, not a trait product.
; ----------------------------------------------------------------------------





(intender suicide-disgrace
  (cooldown 1 m try-once)
  (rng-stream deliberation)
  (role @self {@self pressure [k humiliation] ?target}:?pressure
    (when (and (latch-eval (chance (* (k-grievance-rate)
                                      (* 0.01 (grievance-drive ?pressure ?target 1.0)))))
               (despairing @self)))
    (declare-utility survival)
    (effects (maintain-intent {@self intent DIE [k suicide]} /caused_by ?pressure))))

(intender suicide-grief
  (cooldown 1 m try-once)
  (rng-stream deliberation)
  (role @self {@self pressure [k attachment-loss] ?target}:?pressure
    (when (and (latch-eval (chance (* (k-grievance-rate)
                                      (* 0.03 (grievance-drive ?pressure ?target 1.0)))))
               (despairing @self)))
    (declare-utility survival)
    (effects (maintain-intent {@self intent DIE [k suicide]} /caused_by ?pressure))))

(think strive-rivalry
  (cooldown 1 m try-once)
  (rng-stream deliberation)
  (role @self {@self pressure [k rivalry-pressure] ?target}:?pressure
    (when (chance (* (k-grievance-rate)
                     (* 0.6 (grievance-drive ?pressure ?target 1.0)))))
    (effects (discharge-pressure ?pressure 0.5))))
