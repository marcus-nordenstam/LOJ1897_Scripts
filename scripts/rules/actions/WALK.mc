; ----------------------------------------------------------------------------
; WALK - the one travel act, at both LODs. The `go` TASK reasons about the destination
; (enter a structure, walk into a room); WALK gets there. ?dest is a SPOT and nothing
; else - a point on a floor one man can stand on and hold, so arrival is an overlap and
; there is no box centre to mistake for a floor.
;
; ONE body, and the LOD branch sits at the movement write and nowhere else. Only a
; PRESENTED man on a navmesh navigates: the body plans through the nav graph, polls the
; search, steers the character at the next unpassed waypoint every frame, and on arrival
; relocates him onto the spot and sets its own /succ. Everyone else - every unpresented man, and a presented one where no
; navmesh covers the route - is dumb travel: the act's one cap tick relocates him and the
; cap commits /succ. So the duration is LOD-aware: the scheduled path needs a cap, since
; that tick IS the act, and the steered path must not have one, or it would commit /succ
; at the estimate with the man still in the street.
;
; The PLAYER walks this act too, injected with no spot: his keys put a heading on the act
; every frame and (steer-heading ..) walks it, so key release is what ends him.
;
; WALK_TO was this act under another name. Its nav plan and waypoint steering are the
; nav-* funcs now (Merlin, env/functions/nav_functions.h) and its per-tick character
; writes are (steer-to ..) and (steer-heading ..), the two things that cross to the host.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

(define-func walk-navigates (?dest)
  (and (presented-lod) (nav-navigable @self ?dest)))

(action {@self WALK ?dest}:?WALK
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

  ; A navigating walk starts its search now, so the first effects tick already has a plan
  ; to poll. The player walks where his keys point, to no spot at all.
  (init
    (if (is-npc)
        (then (check (is-spot ?dest))
              (if (walk-navigates ?dest)
                  (then (nav-ensure-path @self ?dest))))))

  (effects
    (cond
      (case (is-player)
        (steer-heading @self))
      (case (not (walk-navigates ?dest))
        (relocate @self ?dest))
      (else
        ; Re-planned when the goal drifts (a destination that is a person moves) or a
        ; crossed passage flipped; otherwise a report. While the search is pending or
        ; working he does NOTHING this tick - no fallback steering through unknown
        ; space, which is the point of the async search.
        (switch (nav-ensure-path @self ?dest)
          (on failed (set-outcome ?WALK /fail))
          (on ready
            ; No "he is already on it" rung before these: (distance ..) is OBB-to-OBB, so a
            ; steer spot reads ZERO as soon as his box touches it - some 0.4 m out - and a
            ; near-zero threshold there latches him in place short of every waypoint.
            ; Both movement writes already refuse a step too short to take, in centre metres.
            (nav-steer-target @self ?dest):?steer
            (if (< (distance @self (travel-spot ?dest)) (walk_arrive_m))
                (then (relocate @self ?dest)
                      (set-outcome ?WALK /succ))
                (else (steer-to @self ?steer))))))))

  ; Runs on every end, and cancels only while this act still owns the plan: a cease
  ; that fires after the OUT fade must not clobber a successor's route.
  (cease (nav-cancel @self ?WALK)))
