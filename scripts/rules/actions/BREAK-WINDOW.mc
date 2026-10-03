; ----------------------------------------------------------------------------
; BREAK-WINDOW ?win - smash a window: it stays where it stands, broken - a permanent passable
; gap, so the leaf is not swung and its opening-status is left as it was. Like FORCE-ENTRY it
; only breaches the way; the enter task's WALK-in step carries the actor through.
; ----------------------------------------------------------------------------

(action {@self BREAK-WINDOW ?win}:?BREAK-WINDOW
  (motor body legs)
  (track-skill-level [k illicit])
  (tar [k object] @object) (duration (seconds 1 min))
  (effects
    (check (spatial ?win co-located @self))
    (set-attr ?win integrity [k broken])
    (set-outcome ?BREAK-WINDOW /succ)))
