; ----------------------------------------------------------------------------
; The INWARD grievance outlets - the two responses that are not acts against the
; grievance's focus, so they are not proposals: they resolve where they fire.
; strive: benign envy. Getting better at the contested domain is not a bespoke act -
;   competence accrues from performing that domain's real acts - so the response just
;   bleeds the rivalry off.
; ----------------------------------------------------------------------------

(think strive-rivalry
  (cooldown 1 m try-once)
  (rng-stream deliberation)
  (role @self {@self pressure [k rivalry-pressure] ?target}:?pressure
    (when (chance (* (k-grievance-rate)
                     (* 0.6 (grievance-drive ?pressure ?target 1.0)))))
    (effects (discharge-pressure ?pressure 0.5))))
