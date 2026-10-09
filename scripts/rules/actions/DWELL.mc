; ----------------------------------------------------------------------------
; dwell (action) - THE shared stay-put primitive: be at ?place UNTIL the
; hour ?until, for whatever reason the proposing think holds (an occasion
; window, idling at home, manning a post between duties, waiting on a meal).
; The aux is an ABSOLUTE boundary hour, never a duration: an interrupted
; dwell's surviving proposal re-aims at the SAME boundary on resumption (the
; action recomputes the minutes at each promotion - the stay's physics). The
; proposer's (when) window must fell the bout at its own boundary, so a stale
; ?until never survives into the next block. Hour 24 is the coming midnight.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

; STAYING PUT IS NOT IDLING. A dwell is proposed for a reason - manning a post between
; duties, waiting out an occasion - so it inherits its proposer's utility and competes on
; it like any other act. It carried (idle-action) once, which made it yield at equal
; utility to anything purposeful, and that is how a man wandered off his shift.
(action {@self DWELL ?place ?until}:?DWELL
  (motor body legs)
  (duration (seconds (minutes-until-hour (modulo ?until (clock_hours))) min))
  (effects (set-outcome ?DWELL /succ)))
