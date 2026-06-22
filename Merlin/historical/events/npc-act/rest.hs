; ----------------------------------------------------------------------------
; rest - the FATIGUE / REST lane (npc-act): a real physiological fatigue model
; drives when an NPC sleeps.
;
; (fatigue @self) reads the continuous, imperceptible `fatigue` attr (0 rested ..
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
; ----------------------------------------------------------------------------

; tired and away from home: go home to rest. Utility climbs with fatigue but
; stays below the work shift (80) until exhaustion, then overrides.
(hsim-event seek_rest
  (intra-day)
  (nl   "@self heads home to rest")
  (when (and (not (under-attack))
             (not (at-home))
             (> (fatigue @self) 0.7)))
  (utility (if (> (fatigue @self) 1.0) 10000 (* 90 (fatigue @self))))
  (effects (go @self (target {@self home ?}))))

; at home and at all tired (or it is night): sleep until the morning alarm. The
; sleep act records a {@self sleep} memory ((does sleep)); its completion resets
; fatigue. Utility skyrockets past full fatigue so sleep dominates work / leisure.
(hsim-event sleep
  (intra-day)
  (nl   "@self sleeps")
  (does SLEEP)
  ; You cannot sleep through an assault - being under attack gates the whole rest
  ; lane OUT, so the fight acts (defend / flee / scream) take over (fight.hs).
  (when (and (not (under-attack))
             (at-home)
             (or (> (fatigue @self) 0.5)
                 (>= (now-hour) 22)
                 (< (now-hour) 6))))
  (utility (if (> (fatigue @self) 1.0)
               10000
               (max (* 90 (fatigue @self))
                    (if (or (>= (now-hour) 22) (< (now-hour) 6)) 100 0))))
  ; Duration is a FUNCTION: sleep until the morning alarm, but no longer than
  ; until a pending obligation - a tired NPC with a gathering tonight wakes in
  ; time to get ready instead of napping straight through it. (min ...) of the
  ; alarm and every constraint; minutes-until-attend is a huge sentinel when no
  ; occasion is pending, so ordinary nights are unaffected.
  ; Duration is a FUNCTION: sleep until the morning alarm, but no longer than
  ; until a pending obligation - a tired NPC with a gathering tonight wakes in
  ; time to get ready instead of napping straight through it. (min ...) of the
  ; alarm and every constraint; minutes-until-attend is a huge sentinel when no
  ; occasion is pending, so ordinary nights are unaffected.
  (effects (act sleep_episode (min (minutes-until-alarm @self)
                                   (minutes-until-attend @self)))))

; completion of the sleep act (completion-only): the engine ends the {@self sleep}
; act-belief and resets fatigue automatically; this just records the wake.
(hsim-event sleep_episode
  (schedule (completion-only))
  (nl   "@self wakes rested")
  (effects
    (log _sleep_episode @self)))

; the mild fallback: anywhere but home with nothing else eligible -> drift home.
(hsim-event idle_go_home
  (intra-day)
  (nl   "@self drifts home")
  (when (and (not (under-attack))
             (not (at-home))))
  (utility 1)
  (effects (go @self (target {@self home ?}))))
