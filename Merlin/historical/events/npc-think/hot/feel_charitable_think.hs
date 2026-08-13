; ----------------------------------------------------------------------------
; The CHARITY lane (B4 pressure model). ONE think:
;   feel_charitable (npc-think): almsgiving is a VIRTUE - a duty-style pressure
;     (like worship) = days-since-last-alms ramp x COMPASSION, capped LOW as a
;     rare leisure act (charity is occasional, not a fixture). The uncompassionate
;     never clear a routine act. At a church -> the give_alms act-goal there; else
;     -> a `go` sub-act-goal to a church (the Victorian charity venue).
;   give_alms_act (npc-action, give_alms.hs): the durative almsgiving - mints the
;     punctual {@self give <sum>} record the generosity classifier reads, ends the
;     act. The {@self give_alms <church>} act-belief IS the episodic memory
;     days-since-last reads. No aim, no end-goal.
;
; COOLDOWN: the drive returns on a ~20-day refractory; the days-since-last ramp is
; the utility SHAPE and the cooldown is the floor.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

; TERMINAL step (act_body_purification): the almsgiving act is PROPOSED, guarded by being AT
; the church, not auto-promoted by the bare {@self give_alms <church>} goal. feel_charitable holds
; that goal at the church (or routes there via enter); the act promotes ONLY here, ONLY in-building.
; The proposal inherits the compassion-ramp drive from the {@self give_alms ?church} goal it
; /causes (via the (goal ...) gate).
(npc-think give_alms_at_church
  (goal    {@self give_alms ?church})
  (when    (in-building @self ?church))
  (effects (maintain-proposal {@self give_alms ?church})))
