; ----------------------------------------------------------------------------
; RUN - WALK at a run. (inherit WALK) IS the body: one travel algorithm, the LOD
; branch at the movement write, the plan in the nav slot. What differs is how it
; looks and how fast it goes - the presentation block - and nothing else. Its
; injected twin (the player's shift-run, no mind, no body) rides the direction steer.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")
(include "../../macros/tunables.mc")

(npc-action {@self RUN ?dest}:?run
  (inherit WALK)
  (presentation
    (anim-male Motion_Male_Run_01)
    (anim-female Motion_Fem_Run_01)
    (state running)
    (movement-speed (run_speed_mps))
    (delib-turn-speed (run_delib_turn_rate))
    (in 0.0) (out 0.0)))
