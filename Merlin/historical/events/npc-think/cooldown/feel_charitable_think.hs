; ----------------------------------------------------------------------------
; The CHARITY lane (B4 pressure model). ONE think:
;   feel_charitable (npc-think): almsgiving is a VIRTUE - a duty-style pressure
;     (like worship) = days-since-last-alms ramp x COMPASSION, capped LOW as a
;     rare leisure act (charity is occasional, not a fixture). The uncompassionate
;     never clear a routine act. At a church -> the give_alms act-goal there; else
;     -> a `go` sub-act-goal to a church (the Victorian charity venue).
;   give_alms_act (npc-action, give_alms.hs): the durative almsgiving - mints the
;     punctual {@self give <sum>} record the generosity classifier reads, ends the
;     act. The {@self GIVE_ALMS <church>} act-belief IS the episodic memory
;     days-since-last reads. No aim, no end-goal.
;
; COOLDOWN: the drive returns on a ~20-day refractory; the days-since-last ramp is
; the utility SHAPE and the cooldown is the floor.
; ----------------------------------------------------------------------------

(include "../../../definitions/roles.hs")

(npc-think feel_charitable
  (cooldown 20 d)
  (role @self (grown @self))
  ; The nearest church the NPC KNOWS (role-cast; no known church -> no fire).
  (role ?venue [k building church] (select (score (near @self ?venue)) (policy roulette)))
  (when (>= (days-since-last {@self GIVE_ALMS /ever}) 20))
  ; compassion x a slow days-since ramp, capped low (rare deep-idle draw); the
  ; uncompassionate stay below every routine act, so they never give.
  (utility (* (attr @self compassion)
              (min (* (days-since-last {@self GIVE_ALMS /ever}) 0.8) 25)))
  (effects
    (debug-print "TRACE-CHARITABLE venue=?venue")
    (if (in-building @self ?venue)
        (then (begin-goal {@self GIVE_ALMS ?venue}))
        (else (maintain-proposal {@self enter ?venue})))))
