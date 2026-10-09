; ----------------------------------------------------------------------------
; WALK - the one travel act, at both LODs. The tasks reason about the destination - go-to walks
; him inside his domain or into the next one, cross takes him through one passage - and WALK
; gets there. ?dest is a SPOT and nothing else - a point on a floor one man can stand on and
; hold, so arrival is his centre standing on that point across the floor, and there is no box
; centre to mistake for a floor. A spot he cannot close in on is refused and the walk fails, so
; his proposer finds him another. Every proposer is go-to or cross (mlint walk-proposer).
;
; The WORLD decides where a walk stops, never what he believes: a way that crosses a passage the
; world holds shut or locked stops before it, he sees it there, and the walk fails with the
; passage in its barred-by - his proposer crosses it on the next look.
;
; ONE body, and the branch sits at the movement write and nowhere else, on the CLOCK first and
; the LOD second. Under the jump clock nothing happens between instants: the act's one cap tick
; relocates him - onto the spot, or before the first passage the world bars on every way there -
; and the cap commits /succ. Under the real clock a PRESENTED man on a navmesh navigates: the
; walk is planned as he sees the world now, the body steers the character at the next unpassed
; waypoint every frame, re-plans when he sees a door it crosses shut, and on arrival relocates him
; onto the spot and sets its own /succ; when the only way lies through a barrier he sees shut,
; the walk ends /fail with the barrier in its barred-by. An unpresented man under the real clock,
; and a presented one where no navmesh covers the route, relocates at the cap tick as under the
; jump clock. So the duration is clock- and LOD-aware: the scheduled path needs a cap, since that
; tick IS the act, and the steered path must not have one, or it would commit /succ at the
; estimate with the man still in the street.
;
; The PLAYER walks this act too, injected with no spot: his keys put a heading on the act
; every frame and (steer-heading ..) walks it, so key release is what ends him.
; ----------------------------------------------------------------------------

(include "../../macros/tunables.mc")

(define-func walk-navigates (?dest)
  (and (real-clock) (presented-lod) (nav-navigable @self ?dest)))

; When the movement task this walk serves began: a barrier he has seen shut since then bars its
; route.
(define-func walk-since (?WALK)
  (start-time (caused-by ?WALK {@self go-to|cross ?})))

; Where the world stops a walk nobody watches: before the first passage it bars on every way to
; ?dest, which he sees there, failing the walk - else on ?dest itself.
(define-func walk-relocate (?WALK ?dest)
  (way-barrier-spot @self ?dest (walk-since ?WALK)): ?stop
  (if (is-spot ?stop)
      (then (bb-write ?WALK barred-by (way-barrier @self ?dest (walk-since ?WALK)))
            (relocate @self ?stop)
            (set-outcome ?WALK /fail))
      (else (relocate @self ?dest))))

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
    (cond (case (and (real-clock) (presented-lod)) procedural)
          (else (seconds (max (go_travel_floor_min)
                              (travel-minutes @self ?dest (default_errand_min)))
                         min))))

  ; A walk a navmesh covers starts its search now, so the first effects tick already has a
  ; plan to poll. The player walks where his keys point, to no spot at all.
  (init
    (if (is-npc)
        (then (check (is-spot ?dest))
              (if (walk-navigates ?dest)
                  (then (nav-ensure-path @self ?dest (walk-since ?WALK)))))))

  (effects
    (cond
      (case (is-player)
        (steer-heading @self))
      (case (jump-clock)
        (walk-relocate ?WALK ?dest))
      (case (not (walk-navigates ?dest))
        (walk-relocate ?WALK ?dest))
      (else
        ; Re-planned when the goal drifts or he sees a door it crosses shut; otherwise a
        ; report. While the search is pending or working he does NOTHING this tick - no
        ; fallback steering through unknown space, which is the point of the async search.
        (switch (nav-ensure-path @self ?dest (walk-since ?WALK))
          (on failed (set-outcome ?WALK /fail))
          (on blocked
            (bb-write ?WALK barred-by (nav-barrier @self))
            (set-outcome ?WALK /fail))
          (on ready
            (nav-steer-target @self ?dest):?steer
            (stand-offset @self ?dest): ?offset
            (if (<= ?offset (walk_arrive_m))
                (then (relocate @self ?dest)
                      (set-outcome ?WALK /succ))
                (else
                  ; The closest he has come, and how long since he last came closer.
                  (if (or (bb-none ?WALK closest)
                          (< ?offset (- (bb-read ?WALK closest) (walk_lock_progress_m))))
                      (then (bb-write ?WALK closest ?offset)
                            (bb-write ?WALK stalled 0.0))
                      (else (bb-write ?WALK stalled (+ (bb-read ?WALK stalled) (act-dt)))))
                  (if (> (bb-read ?WALK stalled) (walk_lock_seconds))
                      (then (refuse-spot ?dest)
                            (set-outcome ?WALK /fail))
                      (else (move @self ?steer)
                            (steer-to @self ?steer))))))))))

  ; Runs on every end, and cancels only while this act still owns the plan: a cease
  ; that fires after the OUT fade must not clobber a successor's route.
  (cease (nav-cancel @self ?WALK)))
