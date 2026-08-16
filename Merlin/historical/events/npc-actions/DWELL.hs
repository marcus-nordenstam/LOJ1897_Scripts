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

(npc-action {@self DWELL ?place ?until}
  (duration (minutes-until-hour ?until))
  (effects (set-outcome {@self DWELL ?place ?until} succ)))
