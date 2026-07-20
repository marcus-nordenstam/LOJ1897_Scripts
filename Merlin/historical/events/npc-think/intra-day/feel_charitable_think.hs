; ----------------------------------------------------------------------------
; The CHARITY lane (B4 pressure model). ONE think:
;   feel_charitable (npc-think): almsgiving is a VIRTUE - a duty-style pressure
;     (like worship) = days-since-last-alms ramp x COMPASSION, capped LOW as a
;     rare leisure act (charity is occasional, not a fixture). The uncompassionate
;     never clear a routine act. At a church -> the give_alms act-goal there; else
;     -> a `go` sub-act-goal to a church (the Victorian charity venue).
;   give_alms_act (npc-act, give_alms.hs): the durative almsgiving - mints the
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
  (sim-window-think)
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
  (cont-fire-effects
    (if (in-building ?venue)
        (begin-goal {@self give_alms ?venue})
        (begin-goal {@self enter ?venue}))))
