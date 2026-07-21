; ----------------------------------------------------------------------------
; go - the shared DUMB TRAVEL act body: relocate the actor INTO a space (room /
; exterior). Any lane that needs the actor somewhere it is not maintains {@self go
; <space>} (a sub-goal of the thing it is really after - drink / worship / an errand);
; that goal, the live leaf, promotes to go_act, which spends the travel time and
; relocates on completion. `go` now ONLY ever targets a SPACE - reaching a building's
; THRESHOLD is go_to_threshold_act (front-park, below), and the generic enter chain
; (enter.hs) composes the two. The completion pass force-ends the act-belief; the
; minter's cease-effects end the go GOAL (§5.11 principle 2 - the act is dumb, it does
; not branch on its destination, teach, mark, or set outcomes).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")
(include "../../macros/tunables.hs")

(npc-act go_act
  (act {@self go ?dest})
  (duration (max (go_travel_floor_min) (travel-minutes @self ?dest)))
  (act-effects
    (relocate @self ?dest)))

; go_to_threshold - the counterpart DUMB travel primitive: reach a structure's THRESHOLD
; (front-park ~1m OUTSIDE its face), never a room center. The enter chain (enter.hs) mints
; {@self go_to_threshold ?s} to bring the actor to a venue's door, where at-threshold reads
; true and perception teaches the entrance; enter_step_in then steps inside. relocate only
; drops an actor at a target's CENTER (inside), so front-park is the ONLY op that yields an
; outside point - hence a separate act, not a branch inside go_act. The completion pass
; force-ends the act-belief; the minter (enter_go_to_threshold) ends the go_to_threshold GOAL
; on its falling edge, so this act carries no end-act / end-goal.
(npc-act go_to_threshold_act
  (act {@self go_to_threshold ?s})
  (duration (max (go_travel_floor_min) (travel-minutes @self ?s)))
  (act-effects
    (front-park @self ?s)
    ; Cross-subsidy (§5.11): a front-park while a find_building search stands ALSO surveys
    ; ?s - its exterior is perceived from the threshold - keeping the search frontier fed,
    ; the coverage the old two-arm go_act gave on a building arrival.
    (if (goal? {@self find_building ?})
        (then (bb-mark ?s surveyed (survey_marker_ttl_cycles))))))
