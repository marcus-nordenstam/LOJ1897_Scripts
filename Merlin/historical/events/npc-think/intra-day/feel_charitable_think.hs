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
; SCHEDULED cooldown (event-cadence Phase 2): the drive is edge/timer-driven - it
; leaves the agenda after proposing and returns on a ~20-day refractory (the
; days-since-last ramp is retained as the utility SHAPE; the cooldown is the floor).
; (if-blocked hold) so the drive still fires once the church/grown gates re-align.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think feel_charitable
  (schedule cooldown 20 d)
  (if-blocked hold)
  (role @self (grown @self))
  ; The nearest church the NPC KNOWS (role-cast; no known church -> no fire).
  (role ?venue [k building church] (select (score (near @self ?venue)) (policy roulette)))
  (when (>= (days-since-last @self give_alms) 20))
  ; compassion x a slow days-since ramp, capped low (rare deep-idle draw); the
  ; uncompassionate stay below every routine act, so they never give.
  (utility (* (attr @self compassion)
              (min (* (days-since-last @self give_alms) 0.8) 25)))
  (effects
    (if (in-building ?venue)
        (then (begin-goal {@self give_alms ?venue}))
        (else (begin-goal {@self enter ?venue})))))

; TERMINAL step (act_body_purification): the almsgiving act is now PROPOSED, guarded by being AT
; the church, not auto-promoted by the bare {@self give_alms <church>} goal. feel_charitable holds
; that goal at the church (or routes there via enter); the act promotes ONLY here, ONLY in-building.
; The proposal inherits the compassion-ramp drive from the {@self give_alms ?church} goal it
; /causes (via the (goal ...) gate). Reactive (schedule always): re-proposes while at the church.
(npc-think give_alms_at_church
  (schedule on-commit)
  (if-blocked hold)
  (goal    {@self give_alms ?church})
  (when    (in-building ?church))
  (effects (maintain-proposal {@self give_alms ?church})))
