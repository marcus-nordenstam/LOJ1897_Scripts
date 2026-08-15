; ----------------------------------------------------------------------------
; walk - the shared DUMB TRAVEL act body: relocate the actor INTO a space (room /
; exterior). The `go` TASK (go.hs) drives it - go reasons about the destination
; (enter a structure, walk into a room), walk just spends the travel time and
; relocates on completion. walk ONLY ever targets a SPACE - reaching a building's
; THRESHOLD is go_to_threshold_action (front-park, below). The completion pass
; force-ends the act-belief (§5.11 principle 2 - the act is dumb, it does not branch
; on its destination, teach, mark, or set outcomes).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")
(include "../../macros/tunables.hs")

(npc-action {@self walk ?dest}
  (duration (max (go_travel_floor_min) (travel-minutes @self ?dest)))
  (effects
    (relocate @self ?dest)))

; go_to_threshold - the counterpart DUMB travel primitive: reach a structure's THRESHOLD
; (front-park ~1m OUTSIDE its face), never a room center. The enter chain (enter.hs) mints
; {@self go_to_threshold ?s} to bring the actor to a venue's door, where at-threshold reads
; true and perception teaches the entrance; enter_step_in then steps inside. relocate only
; drops an actor at a target's CENTER (inside), so front-park is the ONLY op that yields an
; outside point - hence a separate act, not a branch inside go_action. The completion pass
; force-ends the act-belief; the minter (enter_go_to_threshold) ends the go_to_threshold GOAL
; on its falling edge, so this act carries no set-outcome / end-goal.
(npc-action {@self go_to_threshold ?s}
  (duration (max (go_travel_floor_min) (travel-minutes @self ?s)))
  (effects
    (front-park @self ?s)))
