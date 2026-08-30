; ----------------------------------------------------------------------------
; destroy_entity ?thing - the one general act of removing an entity from the
; world (a spent application, a superseded will, a sold listing). Dumb: it only
; destroys. The twin of CREATE_ENTITY.
; ----------------------------------------------------------------------------

(npc-action {@self DESTROY_ENTITY ?thing}
  (duration 1)
  (effects
    (destroy-entity ?thing)
    (set-outcome {@self DESTROY_ENTITY ?thing} /succ)))
