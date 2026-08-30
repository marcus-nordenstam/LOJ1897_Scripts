; ----------------------------------------------------------------------------
; rest (npc-think) - the FATIGUE / REST lane: a real physiological fatigue model
; drives when an NPC sleeps.
;
; (attr @self sleepiness) reads the ADRENALINE-MASKED fatigue (sleepiness = fatigue *
; (1 - adrenaline), derived by update_physiology). The raw `fatigue` attr (0 rested ..
; 1 ready-for-bed, can exceed 1) is the untouched debt; the sleep act's completion REDUCES
; it (1/6 per hour slept -> 6h clears 1.0), waking time accrues it. A combatant reads
; sleepiness ~0 during a fight (adrenaline masks it) then crashes when the surge fades.
; A separate
; appraiser de-quantizes it into {@self alertness alert|tired|sleepy} (the
; queryable memory); this lane and the utility only ever read the attr.
;
; Three intra-day rules, competing by (utility):
;   - seek_rest    : tired and not home -> head home (rises with fatigue).
;   - sleep        : at home -> the durative sleep act ((does sleep) records the
;                    {@self SLEEP} memory; its completion resets fatigue). Utility
;                    climbs with fatigue and SKYROCKETS once fatigue > 1.0, so an
;                    over-tired NPC abandons everything else and goes to bed.
;   - idle_go_home : the mild fallback - when nothing pulls you,
;                    drift home. Lowest priority.
; The durative sleep act itself (sleep_act) lives in npc-act/rest.hs.
; ----------------------------------------------------------------------------

(include "../../../macros/intensity-macros.hs")

; THE SLEEP DRIVE - the banded fatigue escalation, aligned with the engine's alertness
; thresholds (update_physiology: < 0.5 alert, < 1.0 tired, else sleepy; accrual 1/16 per
; waking hour, so 0.8 ~ 19:00 and 1.0 ~ 22:00). Ordinary drowsiness is WANT-tier (it
; loses to work / meals / errands, as the old 90*s^2 value did); NEED engages only when
; genuinely tired late evening (bedtime outranks leisure and duty); CRISIS past the
; collapse knee, so an exhausted NPC abandons everything and beds down. The
; night-onset case (hour >= 22 with low sleepiness) rides the sleep rung's (when)
; hour gate at want-tier, where midnight has no real competitors.
(define-macro sleep-drive ()
  (homeostatic-banded sleepiness 2.0
    (want   0.0  0   400)
    (need   0.8  400 900)
    (crisis 1.0  800 1000)))

; tired and away from home: go home to rest. The drive climbs with fatigue - WANT band
; while merely tired, NEED late evening, CRISIS past the collapse knee, so an exhausted
; NPC abandons everything and heads home.
(npc-think seek_rest
  (when (and (not (at-home))
             (> (attr @self sleepiness) 0.7)))
  (utility (sleep-drive))
  (effects       (any {@self home ?go_dest}) (debug-print "TRACE-SEEKREST home=?go_dest") (maintain-proposal {@self enter ?go_dest})))

; at home and at all tired (or it is night): sleep until the morning alarm. The
; sleep act records a {@self SLEEP} memory ((does sleep)); its completion resets
; fatigue. Utility skyrockets past full fatigue so sleep dominates work / leisure.
(npc-think sleep
  (fatigue 0)                      ; sleep is a bodily need, not a fruitless search - never fatigue-capped
  (role ?home {@self home ?home})
  ; You cannot sleep through an assault - being under attack gates the whole rest
  ; lane OUT, so the fight acts (defend / flee / scream) take over (fight.hs).
  (when (and (at-home)
             (or (> (attr @self sleepiness) 0.5)
                 (>= (now-hour) 22)
                 (< (now-hour) 6))))
  ; Banded fatigue drive (WANT while merely drowsy, NEED late evening, CRISIS past
  ; collapse). The night gate lives in the (when) above: past 22h even a low drive
  ; proposes, and want-tier suffices - midnight has no real competitors.
  (utility (sleep-drive))
  ; Duration is a FUNCTION: sleep until the morning alarm, but no longer than
  ; until a pending obligation - a tired NPC with a gathering tonight wakes in
  ; time to get ready instead of napping straight through it, and an evening
  ; napper wakes for the household supper (the pre-dinner doze; on a normal
  ; NIGHT sleep the next supper hour is ~20h away, far past the alarm, so
  ; nights are unaffected - and an exhausted riser just goes straight back to
  ; bed, the fatigue knee wins the 18:00 re-deliberation). (min ...) of the
  ; alarm and every constraint; minutes-until-attend / -until-hour are huge
  ; sentinels when nothing is pending.
  ; PROPOSE the SLEEP act (act_body_purification): sleep's own (when) - at home + sleepy/night - IS
  ; the precondition, so this propose is the whole terminal. sleep_act carries the duration
  ; + ends the belief; fatigue recovery keys on the SLEEP label at completion.
  (effects       (maintain-proposal {@self SLEEP})))

; the mild fallback: anywhere but home with nothing else eligible -> drift home.
(npc-think idle_go_home
  (when (not (at-home)))
  (utility idle fallback)
  (effects       (any {@self home ?go_dest}) (debug-print "TRACE-IDLEHOME home=?go_dest") (maintain-proposal {@self enter ?go_dest})))
