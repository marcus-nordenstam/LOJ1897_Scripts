; ----------------------------------------------------------------------------
; go_to_threshold - the counterpart DUMB travel primitive: reach a structure's THRESHOLD
; (front-park ~1m OUTSIDE its face), never a room center. The enter chain (enter.hs) mints
; {@self GO_TO_THRESHOLD ?s} to bring the actor to a venue's door, where at-threshold reads
; true and perception teaches the entrance; enter_step_in then steps inside. relocate only
; drops an actor at a target's CENTER (inside), so front-park is the ONLY op that yields an
; outside point - hence a separate act, not a branch inside walk (WALK.hs). The completion pass
; force-ends the act-belief; the minter (enter_go_to_threshold) ends the go_to_threshold GOAL
; on its falling edge, so this act carries no set-outcome / end-goal.
; ----------------------------------------------------------------------------

(include "../../definitions/roles.hs")
(include "../../macros/tunables.hs")

(npc-action {@self GO_TO_THRESHOLD ?s}
  (duration (max (go_travel_floor_min) (travel-minutes @self ?s)))
  (effects
    ; The destination can vanish from the walker's MIND mid-travel (an unreinforced
    ; building object decays) - the completion then reads a null ?s. Park only on a
    ; live target; a decayed one just ends the walk (the force-end owns the belief).
    (if ?s
        (then
          (front-park @self ?s)
          ; POSTCONDITION: front-park's whole purpose is that at-threshold now reads
          ; true (enter_step_in gates on it). A false read here = the park landed
          ; somewhere the threshold test does not accept (geometry / face mismatch) -
          ; the enter chain would silently approach-loop forever.
          (check (at-threshold @self ?s))))))
