; ----------------------------------------------------------------------------
; walk - the shared DUMB TRAVEL act body: relocate the actor to ?dest, which is either
; a SPACE (room / exterior) or a bare world POINT. The `go` TASK (go.hs) drives it - go
; reasons about the destination (enter a structure, walk into a room), walk just spends
; the travel time and relocates on completion. A venue's THRESHOLD is just a point the
; caller computed ((front-park-point ..), funcs/spatial.mc), so there is no second
; travel act for it. The completion pass force-ends the act-belief (§5.11 principle 2 -
; the act is dumb, it does not branch on its destination, teach, mark, or set outcomes).
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")
(include "../../macros/tunables.mc")

(npc-action {@self WALK ?dest}
  (duration (max (go_travel_floor_min) (travel-minutes @self ?dest)))
  (effects
    (debug-print "@self WALK to ?dest")
    (relocate @self ?dest)))
