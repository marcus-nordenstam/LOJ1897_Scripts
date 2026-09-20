; ----------------------------------------------------------------------------
; RUN - WALK at a run. The body is WALK's, written out in full: one travel algorithm,
; the LOD branch at the movement write, the plan in the nav slot. What differs is how it
; looks and how fast it goes - the presentation block - and nothing else. Its injected
; twin (the player's shift-run, no mind, no body) rides the engine's direction steer.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")
(include "../../macros/tunables.mc")

(npc-action {@self RUN ?dest}:?run
  (motor legs)
  (obs)
  (tar @excl)
  (belief-timeout 600)
  (presentation
    (anim-male Motion_Male_Run_01)
    (anim-female Motion_Fem_Run_01)
    (anim-flags loop reset)
    (state running)
    (movement-speed (run_speed_mps))
    (delib-turn-speed (run_delib_turn_rate))
    (preroll 0.0) (in 0.0) (out 0.0))
  (duration
    (cond (case (presented-lod) procedural)
          (else (seconds (max (go_travel_floor_min) (travel-minutes @self ?dest)) min))))

  (init
    (cond
      (case (unsubstantial ?dest) (set-outcome ?run /fail))
      (case (nav-navigable @self ?dest) (nav-ensure-path @self ?dest))))

  (effects
    (cond
      (case (not (nav-navigable @self ?dest))
        (relocate @self ?dest))
      (else
        (switch (nav-ensure-path @self ?dest)
          (on failed (set-outcome ?run /fail))
          (on ready
            (nav-steer-target @self ?dest):?steer
            (cond
              (case (< (distance @self ?steer) (walk_step_eps)))
              (case (< (distance @self (travel-point ?dest)) (walk_arrive_m))
                (set-outcome ?run /succ))
              (case (presented-lod)
                (steer-to @self ?steer))
              (else
                (advance-toward @self ?steer (act-dt)))))))))

  (cease (nav-cancel @self ?run)))
