; ----------------------------------------------------------------------------
; walk - the shared DUMB TRAVEL act body: relocate the actor to ?dest, which is either
; a SPACE (room / exterior) or a bare world POINT. The `go` TASK (go.hs) drives it - go
; reasons about the destination (enter a structure, walk into a room), walk just spends
; the travel time and relocates on completion. A venue's THRESHOLD is just a point the
; caller computed ((front-park-point ..), funcs/spatial.mc), so there is no second
; travel act for it. The completion pass force-ends the act-belief (§5.11 principle 2 -
; the act is dumb, it does not branch on its destination, teach, mark, or set outcomes).
;
; WALK_TO WAS THIS ACT UNDER ANOTHER NAME and is gone. The .act port minted it as a
; second label because a C++ handler registered under that spelling; an action is ONE
; label, and WALK_TO.act even carried `alias = WALK` to borrow this one's animation
; (action_unification_plan.md 4.1). What came across is its declaration - the legs
; motor, the observability, the 600s belief timeout - and its TIMINGS, which are the
; deliberated steered act's (in / out 0.4, turn rate 4.0) rather than the injected
; player walk's. Its `run = ?` was the PRESENTED length: a steered walk ends on
; ARRIVAL and must not carry a cap, or it would commit /succ at the estimate while the
; man was still in the street. The scheduled length below stands until a (duration ..)
; expression can branch on the LOD (2.3), which is the same gap the steering body
; waits on.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.mc")
(include "../../macros/tunables.mc")

(npc-action {@self WALK ?dest}
  (motor legs)
  (obs)
  (tar @excl)
  (belief-timeout 600)
  (presentation
    (anim-male Motion_Male_Walk_Normal_01)
    (anim-female Motion_Fem_Walk_Normal_01)
    (anim-flags loop reset)
    (state walking)
    (movement-speed 0.1)
    (delib-turn-speed 4.0)
    (preroll 0.0) (in 0.4) (out 0.4))
  (duration (minutes (max (go_travel_floor_min) (travel-minutes @self ?dest))))
  (effects
    ; A destination nobody can point to is not one. The relocate seam takes a POINT as
    ; readily as a space, and the vector ops read a failed geometry read as the ZERO
    ; vector - so an unresolved venue walks the body to the world origin and it never
    ; comes back. The act asserts its own precondition instead.
    (check (substantial ?dest))
    (relocate @self ?dest)))
