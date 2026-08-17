; ----------------------------------------------------------------------------
; dwell (npc-action) - THE shared stay-put primitive: be at ?place UNTIL the
; hour ?until, for whatever reason the proposing think holds (an occasion
; window, idling at home, manning a post between duties, waiting on a meal).
; The aux is an ABSOLUTE boundary hour, never a duration: an interrupted
; dwell's surviving proposal re-aims at the SAME boundary on resumption (the
; action recomputes the minutes at each promotion - the stay's physics). The
; proposer's (when) window must fell the bout at its own boundary, so a stale
; ?until never survives into the next block.
; ----------------------------------------------------------------------------

; The duration is CAPPED at a re-deliberation quantum: dwell is the idle
; fallback, so it must never hoard the body across a stretch where a real task
; could run. It still AIMS at ?until (the proposing think re-maintains it each
; quantum until its window closes), but completes every quantum so the mind
; re-deliberates and ANY non-idle task - eligible only now, gated on a clock the
; running act cannot see - preempts it. Without the cap a 3-hour idle block
; starves every errand that becomes eligible inside it.
(npc-action {@self DWELL ?place ?until}
  (duration (min (minutes-until-hour ?until) (dwell_quantum_minutes)))
  (effects (set-outcome {@self DWELL ?place ?until} succ)))
