; ----------------------------------------------------------------------------
; SUPER-RUN - WALK at a sprint, and the player's alone. Nothing proposes it: it exists
; so a developer can cross the town on foot to look at something, and it is injected on
; the player's legs the way WALK and RUN are (CTRL+W).
;
; (inherit WALK) IS the body - one travel algorithm, the LOD branch at the movement
; write, the plan in the nav slot. The presentation is the run's, because a walk cycle
; played at this speed reads as a man being dragged, and the speed is the point.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

(npc-action {@self SUPER-RUN ?dest}:?run
  (inherit WALK)
  (presentation
    (anim-male Motion_Male_Run_01)
    (anim-female Motion_Fem_Run_01)
    (state running)
    (movement-speed (super_run_speed_mps))
    (delib-turn-speed (run_delib_turn_rate))
    (in 0.0) (out 0.0)))
