; ----------------------------------------------------------------------------
; walk - the shared DUMB TRAVEL act body: relocate the actor INTO a space (room /
; exterior). The `go` TASK (go.hs) drives it - go reasons about the destination
; (enter a structure, walk into a room), walk just spends the travel time and
; relocates on completion. walk ONLY ever targets a SPACE - reaching a building's
; THRESHOLD is go_to_threshold (front-park, GO_TO_THRESHOLD.hs). The completion pass
; force-ends the act-belief (§5.11 principle 2 - the act is dumb, it does not branch
; on its destination, teach, mark, or set outcomes).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")
(include "../../macros/tunables.mc")

(npc-action {@self WALK ?dest}
  (duration (max (go_travel_floor_min) (travel-minutes @self ?dest)))
  (effects
    (relocate @self ?dest)))
