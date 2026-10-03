; ----------------------------------------------------------------------------
; FORCE-ENTRY ?door - break a locked door: it swings open and stays broken, unlocked and ajar.
; Does NOT move the actor inside - it only breaches the way so the enter task's WALK-in step
; can path through. A permanent, perceivable change (a forced door stays broken).
; ----------------------------------------------------------------------------

(action {@self FORCE-ENTRY ?door}:?FORCE-ENTRY
  (motor body legs)
  (track-skill-level [k illicit])
  (tar [k object] @object) (duration (seconds 2 min))
  (effects
    (check (spatial ?door co-located @self))
    (articulate ?door 1.0)
    (set-attr ?door integrity [k broken])
    (set-attr ?door lock-status [k unlocked])
    (set-attr ?door opening-status [k ajar])
    (set-outcome ?FORCE-ENTRY /succ)))
