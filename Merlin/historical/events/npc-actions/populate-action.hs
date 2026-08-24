; ----------------------------------------------------------------------------
; populate (npc-action) - the world-gen founder pass, authored as content.
;
; Fired ONCE, actorless, by the engine (run_populate_action) BEFORE the startup
; rounds - it is NOT proposed or deliberated (world-gen has no actor). Its effects
; mint the founder population via (make-human): the engine's content-free NPC funnel
; (entity + Mendelian traits + kin + adult birth date). (make-human) with no ?at lets
; the engine place each founder - consecutive calls land a FOUNDING PAIR per building
; (keyed on the running headcount), spreading founders across the town's residences.
;
; The count is the whole population POLICY that lives here, in content. Later slices
; move the building choice + distributions (class / family structure) into these
; effects too, over an env-truth building list.
; ----------------------------------------------------------------------------

(npc-action {@self populate}
  (duration 1)
  (effects
    (make-human)))
