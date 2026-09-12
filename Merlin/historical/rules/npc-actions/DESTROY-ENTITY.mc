; ----------------------------------------------------------------------------
; destroy_entity ?thing - the one general act of removing an entity from the
; world (a spent application, a superseded will, a sold listing). The twin of
; CREATE-ENTITY.
;
; The realization comes FIRST: @self's own act is about to take the thing out of the
; world, so every ongoing belief he holds about it ends (a tense flip - "it WAS in my
; hand" stands as history) and it goes onto the condition axis as consumed. Without
; that his beliefs outlive the thing, and a rule still gating on one reaches for a
; referent the world no longer has. The @excl body-state axes are what the sweep
; keeps - see realize-destroyed.
; ----------------------------------------------------------------------------

(npc-action {@self DESTROY-ENTITY ?thing}
  (duration 1)
  (effects
    (realize-destroyed ?thing condition [k condition consumed])
    (destroy-entity ?thing)
    (set-outcome {@self DESTROY-ENTITY ?thing} /succ)))
