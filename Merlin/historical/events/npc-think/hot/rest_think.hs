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

(include "../../../macros/intensity_macros.hs")

; tired and away from home: go home to rest. The homeostatic drive climbs with fatigue -
; a soft pull below the work shift (80) when merely tired, diverging past it toward the
; sleepiness danger limit (2.0), so an exhausted NPC abandons everything and heads home.
(npc-think seek_rest
  (when (and (not (at-home))
             (> (attr @self sleepiness) 0.7)))
  (utility (homeostatic sleepiness 2.0 90))
  (effects       (any {@self home ?}).target: ?go_dest (debug-print "TRACE-SEEKREST home=?go_dest") (maintain-proposal {@self enter ?go_dest})))

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
  ; Convex fatigue drive (diverges toward the sleepiness danger limit), floored at
  ; night so an NPC beds down on time even when not yet tired.
  (utility (max (homeostatic sleepiness 2.0 90)
                (if (or (>= (now-hour) 22) (< (now-hour) 6)) (then 100) (else 0))))
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
  (utility 1)
  (effects       (any {@self home ?}).target: ?go_dest (debug-print "TRACE-IDLEHOME home=?go_dest") (maintain-proposal {@self enter ?go_dest})))
