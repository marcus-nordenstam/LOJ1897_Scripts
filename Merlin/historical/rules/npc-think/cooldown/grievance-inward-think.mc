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

(include "../../../definitions/roles.mc")

; despair = stress x (1 - contentment) - the self-belief reading behind the gate.
(define-macro despair (?who)
  (* (any {?who stress}).target (- 1 (any {?who contentment}).target)))

; A confidant to witness ?who's ideation - their living spouse, else the first friend
; they know (read from ?who's OWN relations). The rare servant-only confidant is not
; modelled; the truly alone die unwitnessed.
(define-macro pick-confidant (?who)
  (if (alive (spouse-of ?who))
      (then (spouse-of ?who))
    (else (any {?who friend ?}).target)))

(define-macro resolve-suicide (?who)
  (do
    (if (pick-confidant ?who)
        (then
          (pick-confidant ?who): ?conf
          (begin-belief ?conf {@self mention [k death-cause suicide]})))
    (if (and (>= (despair ?who) (suicide_despair_min))
             (>= (attr ?who withdrawal) (suicide_withdrawal_min)))
        (then (settle-death ?who)
            (set-attr ?who death-cause [k death-cause suicide])))))

(npc-think suicide_disgrace
  (cooldown 1 m)
  (rng-stream deliberation)
  (role @self {@self pressure [k humiliation] ?target}:?pressure)
  (when (chance (* (k-grievance-rate)
                   (* 0.01 (grievance-drive ?pressure ?target 1)))))
  (effects (resolve-suicide @self)))

(npc-think suicide_grief
  (cooldown 1 m)
  (rng-stream deliberation)
  (role @self {@self pressure [k attachment-loss] ?target}:?pressure)
  (when (chance (* (k-grievance-rate)
                   (* 0.03 (grievance-drive ?pressure ?target 1)))))
  (effects (resolve-suicide @self)))

(npc-think strive_rivalry
  (cooldown 1 m)
  (rng-stream deliberation)
  (role @self {@self pressure [k rivalry-pressure] ?target}:?pressure)
  (when (chance (* (k-grievance-rate)
                   (* 0.6 (grievance-drive ?pressure ?target 1)))))
  (effects (discharge-pressure ?pressure 0.5)))
