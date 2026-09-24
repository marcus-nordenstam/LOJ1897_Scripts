; ----------------------------------------------------------------------------
; WALK - the one travel act, at both LODs. The `go` TASK reasons about the destination
; (enter a structure, walk into a room); WALK gets there. ?dest is an env-CELL and nothing
; else - a spot on the grid one man can stand on and hold, so arrival is an overlap and
; there is no box centre to mistake for a floor.
;
; ONE body, and the LOD branch sits at the movement write and nowhere else. Where no
; navmesh covers the route - hsim's whole world - the act is dumb travel: its one cap
; tick relocates and the cap commits /succ. Where a navmesh does, the body plans through
; the nav graph, polls the search, steers at the next unpassed waypoint every tick and
; sets its own /succ on arrival; the presented write turns the character, the
; unpresented one moves the box. So the duration is LOD-aware: the scheduled path needs
; a cap, since that tick IS the act, and the steered path must not have one, or it would
; commit /succ at the estimate with the man still in the street.
;
; WALK_TO was this act under another name. Its nav plan and waypoint steering are the
; nav-* funcs now (Merlin, env/functions/nav_functions.h) and its per-tick character
; write is (steer-to ..), the one thing that crosses to the host.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

(npc-action {@self WALK ?dest}:?walk
  (motor legs)
  (obs)
  (tar @excl)
  (belief-timeout 600)
  (presentation
    (anim-male Motion_Male_Walk_Normal_01)
    (anim-female Motion_Fem_Walk_Normal_01)
    (anim-flags loop reset)
    (state walking)
    (movement-speed (walk_speed_mps))
    (delib-turn-speed (walk_delib_turn_rate))
    (preroll 0.0) (in 0.4) (out 0.4))
  (duration
    (cond (case (presented-lod) procedural)
          (else (seconds (max (go_travel_floor_min) (travel-minutes @self ?dest)) min))))

  ; Where the ground is navigable the search starts now, so the first effects tick
  ; already has a plan to poll.
  (init
    (check (is-cell ?dest))
    (check (or (is-abs-cell ?dest) (substantial (cell-anchor ?dest))))
    (if (nav-navigable @self ?dest)
        (then (nav-ensure-path @self ?dest))))

  (effects
    (cond
      (case (not (nav-navigable @self ?dest))
        (relocate @self ?dest))
      (else
        ; Re-planned when the goal drifts (a destination that is a person moves) or a
        ; crossed passage flipped; otherwise a report. While the search is pending or
        ; working he does NOTHING this tick - no fallback steering through unknown
        ; space, which is the point of the async search.
        (switch (nav-ensure-path @self ?dest)
          (on failed (set-outcome ?walk /fail))
          (on ready
            ; No "he is already on it" rung before these: (distance ..) is OBB-to-OBB, so a
            ; 0.2 m steer cell reads ZERO as soon as his box touches it - some 0.4 m out -
            ; and a near-zero threshold there latches him in place short of every waypoint.
            ; Both movement writes already refuse a step too short to take, in centre metres.
            (nav-steer-target @self ?dest):?steer
            (cond
              (case (< (distance @self (travel-cell ?dest)) (walk_arrive_m))
                (set-outcome ?walk /succ))
              (case (presented-lod)
                (steer-to @self ?steer))
              (else
                (advance-toward @self ?steer (act-dt)))))))))

  ; Runs on every end, and cancels only while this act still owns the plan: a cease
  ; that fires after the OUT fade must not clobber a successor's route.
  (cease (nav-cancel @self ?walk)))
