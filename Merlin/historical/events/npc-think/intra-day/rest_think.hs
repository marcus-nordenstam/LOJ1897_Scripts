; ----------------------------------------------------------------------------
; rest (npc-think) - the FATIGUE / REST lane: a real physiological fatigue model
; drives when an NPC sleeps.
;
; (attr @self fatigue) reads the continuous, imperceptible `fatigue` attr (0 rested ..
; 1 ready-for-bed, can exceed 1 when sleep is denied). The stepper mutates it:
; the sleep act's completion REDUCES it (1/6 per hour slept -> 6h clears 1.0),
; waking time ACCRUES it (~1/16 per hour -> ~1.0 by late evening). A separate
; appraiser de-quantizes it into {@self alertness alert|tired|sleepy} (the
; queryable memory); this lane and the utility only ever read the attr.
;
; Three intra-day rules, competing by (utility):
;   - seek_rest    : tired and not home -> head home (rises with fatigue).
;   - sleep        : at home -> the durative sleep act ((does sleep) records the
;                    {@self sleep} memory; its completion resets fatigue). Utility
;                    climbs with fatigue and SKYROCKETS once fatigue > 1.0, so an
;                    over-tired NPC abandons everything else and goes to bed.
;   - idle_go_home : the mild fallback - when nothing pulls you,
;                    drift home. Lowest priority.
; The durative sleep act itself (sleep_act) lives in npc-act/rest.hs.
; ----------------------------------------------------------------------------

; tired and away from home: go home to rest. Utility climbs with fatigue but
; stays below the work shift (80) until exhaustion, then overrides.
(npc-think seek_rest
  (short-term-think)
  (when (and (not (under-attack))
             (not (at-home))
             (> (attr @self fatigue) 0.7)))
  (utility (if (> (attr @self fatigue) 1.0) 10000 (* 90 (attr @self fatigue))))
  (cont-fire-effects (bind (target {@self home ?}) ?go_dest) (go-into ?go_dest)))

; at home and at all tired (or it is night): sleep until the morning alarm. The
; sleep act records a {@self sleep} memory ((does sleep)); its completion resets
; fatigue. Utility skyrockets past full fatigue so sleep dominates work / leisure.
(npc-think sleep
  (short-term-think)
  (fatigue-timeout 0)              ; sleep is a bodily need, not a fruitless search - never fatigue-capped
  (role ?home (believes {@self home ?home}))
  ; You cannot sleep through an assault - being under attack gates the whole rest
  ; lane OUT, so the fight acts (defend / flee / scream) take over (fight.hs).
  (when (and (not (under-attack))
             (at-home)
             (or (> (attr @self fatigue) 0.5)
                 (>= (now-hour) 22)
                 (< (now-hour) 6))))
  (utility (if (> (attr @self fatigue) 1.0)
               10000
               (max (* 90 (attr @self fatigue))
                    (if (or (>= (now-hour) 22) (< (now-hour) 6)) 100 0))))
  ; Duration is a FUNCTION: sleep until the morning alarm, but no longer than
  ; until a pending obligation - a tired NPC with a gathering tonight wakes in
  ; time to get ready instead of napping straight through it, and an evening
  ; napper wakes for the household supper (the pre-dinner doze; on a normal
  ; NIGHT sleep the next supper hour is ~20h away, far past the alarm, so
  ; nights are unaffected - and an exhausted riser just goes straight back to
  ; bed, the fatigue knee wins the 18:00 re-deliberation). (min ...) of the
  ; alarm and every constraint; minutes-until-attend / -until-hour are huge
  ; sentinels when nothing is pending.
  ; mint the SLEEP act-goal; at home (the leaf) it promotes to sleep_act, which carries
  ; the duration + ends the belief. Fatigue recovery keys on the SLEEP label at completion.
  (cont-fire-effects (excl-goal {@self SLEEP})))

; the mild fallback: anywhere but home with nothing else eligible -> drift home.
(npc-think idle_go_home
  (short-term-think)
  (when (and (not (under-attack))
             (not (at-home))))
  (utility 1)
  (cont-fire-effects (bind (target {@self home ?}) ?go_dest) (go-into ?go_dest)))
