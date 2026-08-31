; ----------------------------------------------------------------------------
; FORCE_ENTRY ?door - break a locked door: mark it broken, unlocked and ajar. Does NOT
; move the actor inside - it only flips the opening so the enter chain's WALK-in step
; can path through. A permanent, perceivable change (a forced door stays broken).
; ----------------------------------------------------------------------------

(npc-action {@self FORCE_ENTRY ?door}:?fe-rel
  (tar object) (duration 2)
  (effects
    (check (spatial ?door co-located @self))
    (set-attr ?door integrity [k broken])
    (set-attr ?door lock_status [k unlocked])
    (set-attr ?door opening_status [k ajar])
    (set-outcome ?fe-rel /succ)))
